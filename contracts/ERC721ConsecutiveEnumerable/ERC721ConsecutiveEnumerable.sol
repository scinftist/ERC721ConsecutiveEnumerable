// SPDX-License-Identifier: MIT
// based on OpenZeppelin Contracts (last updated v4.8.2)
// Created by sciNFTist.eth

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/interfaces/IERC2309.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {Checkpoints} from "@openzeppelin/contracts/utils/structs/Checkpoints.sol";

// import {Checkpoints} from     "../../../utils/structs/Checkpoints.sol";

contract ERC721ConsecutiveEnumerable is ERC721, IERC721Enumerable, IERC2309 {
    using BitMaps for BitMaps.BitMap;
    using Checkpoints for Checkpoints.Trace160;

    Checkpoints.Trace160 private _sequentialOwnership;
    BitMaps.BitMap private _sequentialBurn;

    // Mapping from owner to list of owned token IDs (some values are available virtualy to access use _ownerTokenByIndex(_owner,_index) )
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list(some values are available virtualy to access use _ownerIndexByToken(_tokenId))
    mapping(uint256 => uint256) private _ownedTokensIndex;

    //list of all tokenId available(some values are available virtauly to access use tokenByIndex(_index))
    mapping(uint256 => uint256) private _allIndexToTokenId;
    //mapping of tokenId to index in _allIndexToTokenId(some value are available virtual to access use _indexByToken(tokenId))
    mapping(uint256 => uint256) private _allTokenIdToIndex;
    // number of tokens minted byond consecutiveSupply range
    uint256 private _mintCounter;
    // number of token burned inside consecutiveSupply range
    uint256 private _burnCounter;

    ////-------starting tokenId for batch minters
    mapping(address => uint256) private _ownerStartTokenId;

    ////////-------------------------
    /**
     * @dev some minor changes to ERC721Consecutive
     * @param receivers should be list of unique user(no duplicates)
     * @param amounts amounts can be more than 5000 and emiting consecutiveTransfer() event will be handled in batches of 5000 at most. see _mintConsecutive()
     * @param amounts can not be equal to 1, for single minting use _mint, this was forced to avoid trigering {_afterTokenTransfer} during batch minting.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory receivers,
        uint96[] memory amounts
    ) ERC721(name_, symbol_) {
        for (uint256 i = 0; i < receivers.length; ++i) {
            uint96 a = _mintConsecutive(receivers[i], amounts[i]);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721) returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view virtual override returns (uint256) {
        require(
            index < ERC721.balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownerTokenByIndex(owner, index); //see _ownerTokenByIndex(owner, index)
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalConsecutiveSupply() + _mintCounter - _burnCounter;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    /**
     * @dev handling tokens index virtualy
     */
    function tokenByIndex(
        uint256 index
    ) public view virtual override returns (uint256) {
        require(
            index < ERC721ConsecutiveEnumerable.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        uint256 virtualIndex = _allIndexToTokenId[index];
        //if mapping is empty, index is the same as tokenId, since they are all sequential and start from 0
        if (virtualIndex == 0) {
            return index;
        }
        return virtualIndex - 1; //decrement one (-1) to get the value,overflow is impossible becuase the virtualIndex is not 0.
    }

    /**
     * @dev See {ERC721-_ownerOf}. Override that checks the sequential ownership structure for tokens that have
     * been minted as part of a batch, and not yet transferred.
     */
    function _ownerOf(
        uint256 tokenId
    ) internal view virtual override returns (address) {
        address owner = super._ownerOf(tokenId);
        // If token is owned by the core, or beyond consecutive range, return base value
        if (owner != address(0) || tokenId > type(uint96).max) {
            return owner;
        }
        // Otherwise, check the token was not burned, and fetch ownership from the anchors
        // Note: no need for safe cast, we know that tokenId <= type(uint96).max
        return
            _sequentialBurn.get(tokenId)
                ? address(0)
                : address(_sequentialOwnership.lowerLookup(uint96(tokenId)));
    }

    // see ERC721Consecutive.sol
    function _mint(address to, uint256 tokenId) internal virtual override {
        if (address(this).code.length == 0) {
            revert("single minting during construction is forbidden");
        }

        super._mint(to, tokenId);
    }

    /**
     *
     *
     * @dev See {ERC721-_beforeTokenTransfer}, Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * hook modified for consecutive transfer while maintaning enumarability
     */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        //enumeration operations does not triger during batch minting and instead will be handled virtualy.
        if (batchSize > 1) {
            require(
                address(this).code.length > 0,
                "batch minting is restricted to constructor"
            );
        } else {
            if (from == address(0)) {
                _addTokenToAllTokensEnumeration(tokenId);
            } else if (from != to) {
                _removeTokenFromOwnerEnumeration(from, tokenId);
            }
            if (to == address(0)) {
                _removeTokenFromAllTokensEnumeration(tokenId);
            } else if (to != from) {
                _addTokenToOwnerEnumeration(to, tokenId);
            }
        }
    }

    /**
     * @dev See {ERC721-_afterTokenTransfer}. Burning of tokens that have been sequentially minted must be explicit.
     */

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (to == address(0)) {
            require(
                batchSize == 1,
                "ERC721Consecutive: batch burn not supported"
            );
            if (firstTokenId < _totalConsecutiveSupply()) {
                _sequentialBurn.set(firstTokenId);
                _burnCounter += 1;
            } else {
                _mintCounter -= 1;
            }
        }

        if (from == address(0) && batchSize == 1) {
            if (firstTokenId < _totalConsecutiveSupply()) {
                _burnCounter -= 1;
                _sequentialBurn.unset(firstTokenId);
            } else {
                _mintCounter += 1;
            }
        }

        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }

    //like tokenOfOwnerByIndex but does NOT revert
    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function _ownerTokenByIndex(
        address owner,
        uint256 index
    ) private view returns (uint256) {
        uint256 virtual_tokenId = _ownedTokens[owner][index];
        //if there is noting is stored in the mapping, consider tokenId sequentialy from _ownerStartTokenId[owner]
        if (virtual_tokenId == 0) {
            return index + _ownerStartTokenId[owner]; //new
        } else {
            return virtual_tokenId - 1; //decrement one (-1) to get the value,overflow is impossible becuase the virtual_tokenId is not 0.
        }
    }

    //finding the index of a token in tokens list that owned by the owner
    function _ownerIndexByToken(
        uint256 tokenId
    ) private view returns (uint256) {
        //if there is noting is stored in the mapping, consider index sequentialy from _ownerStartTokenId[_owner]
        uint256 virtual_index = _ownedTokensIndex[tokenId];
        if (virtual_index == 0) {
            address _owner = _ownerOf(tokenId);
            return tokenId - _ownerStartTokenId[_owner];
        } else {
            return virtual_index - 1; //decrement one (-1) to get the value,overflow is impossible becuase the virtual_Index is not 0.
        }
    }

    ////provied the token Index in the list of all tokens that have been created.
    function _indexByToken(uint256 tokenId) private view returns (uint256) {
        uint256 virtualIndex = _allTokenIdToIndex[tokenId];
        //if mapping is empty, tokenId is the same as index, since they are all sequential and start from 0
        if (virtualIndex == 0) {
            return tokenId;
        }
        return virtualIndex - 1; //decrement one (-1) to get the value,overflow is impossible becuase the virtualIndex is not 0.
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     * write values + 1 to avoid confussion to mapping default value of uint (uint(0))
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        // + 1 to remove the ambiguity of value with default value(uint 0) in mapping of  _ownedTokens and _ownedTokensIndex
        _ownedTokens[to][length] = tokenId + 1;
        _ownedTokensIndex[tokenId] = length + 1;
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     * write values + 1 to avoid confussion to mapping default value of uint (uint(0))
     */
    function _removeTokenFromOwnerEnumeration(
        address from,
        uint256 tokenId
    ) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        // uint256 tokenIndex = _ownedTokensIndex[tokenId];
        uint256 tokenIndex = _ownerIndexByToken(tokenId);

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            // uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            uint256 lastTokenId = _ownerTokenByIndex(from, lastTokenIndex); //[from][lastTokenIndex];
            // + 1 to remove the ambiguity of value with default value(uint 0) in mapping of  _ownedTokens and _ownedTokensIndex
            _ownedTokens[from][tokenIndex] = lastTokenId + 1; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex + 1; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     * write values + 1 to avoid confussion to mapping default value of uint (uint(0))
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        uint256 _index = totalSupply();
        // + 1 to remove the ambiguity of value with default value(uint 0) in mapping of  _allIndexToTokenId and _allTokenIdToIndex
        _allIndexToTokenId[_index] = tokenId + 1;
        _allTokenIdToIndex[tokenId] = _index + 1;
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but works with to new mapping _allIndexToTokenId, _allTokenIdToIndex
     * functionality is more similar to _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastIndex = totalSupply() - 1;
        // uint256 tokenIndex = tokenByIndex(tokenId);
        uint256 tokenIndex = _indexByToken(tokenId);

        if (lastIndex != tokenIndex) {
            uint256 lastTokenId = tokenByIndex(lastIndex);
            // + 1 to remove the ambiguity of value with default value(uint 0) in mapping of  _allIndexToTokenId and _allTokenIdToIndex
            _allIndexToTokenId[tokenIndex] = lastTokenId + 1;
            _allTokenIdToIndex[lastTokenId] = tokenIndex + 1;
        }
        delete _allIndexToTokenId[lastIndex];
        delete _allTokenIdToIndex[tokenId];
    }

    //see ERC721Consecutive.sol // omited for now and set to 5k
    // function _maxBatchSize() internal view virtual returns (uint96) {
    //     return 5000;
    // }

    // private
    function _mintConsecutive(
        address to,
        uint96 batchSize
    ) private returns (uint96) {
        uint96 first = _totalConsecutiveSupply();

        // minting a batch of size 0 is a no-op//require batchSize > 1
        if (batchSize > 0) {
            require(
                address(this).code.length > 0,
                "ERC721Consecutive: batch minting restricted to constructor"
            );
            require(
                to != address(0),
                "ERC721Consecutive: mint to the zero address"
            );
            // require(
            //     batchSize <= _maxBatchSize(),
            //     "ERC721Consecutive: batch too large"
            // );
            // for not trigerimg {_afterTokenTransfer} during batch minting
            require(batchSize > 1, "for single Mint use _mint()");
            require(
                ERC721.balanceOf(to) == 0,
                "each account can batch mint once"
            );

            // hook before
            _beforeTokenTransfer(address(0), to, first, batchSize);
            _increaseBalance(to, batchSize);
            /*
             *new
             */
            _ownerStartTokenId[to] = first; //storing start token id of batch minting to batch minter address
            // push an ownership checkpoint & emit event
            uint96 last = first + batchSize - 1;
            _sequentialOwnership.push(last, uint160(to));
            //emit in bundle of 5k
            while (first < last) {
                if (last - first > 5000) {
                    emit ConsecutiveTransfer(
                        first,
                        first + 4999,
                        address(0),
                        to
                    );
                    first = first + 5000;
                } else {
                    emit ConsecutiveTransfer(first, last, address(0), to);
                    first = first + 5000;
                }
            }
            // emit ConsecutiveTransfer(first, last, address(0), to);

            // hook after
            _afterTokenTransfer(address(0), to, first, batchSize);
        }

        return first;
    }

    function _totalConsecutiveSupply() internal view returns (uint96) {
        (bool exists, uint96 latestId, ) = _sequentialOwnership
            .latestCheckpoint();
        return exists ? latestId + 1 : 0;
    }
}
