// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts@4.7.0/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts@4.7.0/token/ERC721/IERC721Receiver.sol";
// import "@openzeppelin/contracts@4.7.0/token/ERC721/extensions/IERC721Metadata.sol";
// import "@openzeppelin/contracts@4.7.0/utils/Address.sol";
// import "@openzeppelin/contracts@4.7.0/utils/Context.sol";
// import "@openzeppelin/contracts@4.7.0/utils/Strings.sol";
// import "@openzeppelin/contracts@4.7.0/utils/introspection/ERC165.sol";

// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/IERC721.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/IERC721Receiver.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/extensions/IERC721Metadata.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Address.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Context.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Strings.sol";
// import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/introspection/ERC165.sol";
import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/interfaces/IERC2309.sol";
import "OpenZeppelin/openzeppelin-contracts@4.8.0/contracts/utils/structs/BitMaps.sol";

contract ERC721CE is ERC721, IERC721Enumerable, IERC2309 {
    using BitMaps for BitMaps.BitMap;
    BitMaps.BitMap private _sequentialBurn;

    address private immutable _preOwner;
    uint256 private _maxSupply;
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;
    ///---mapping from allTokenIDs to index
    //mapping all index to tokenID
    mapping(uint256 => uint256) private _allIndexToTokenId;
    mapping(uint256 => uint256) private _allTokenToIndex;
    uint256 private _mintCounter;
    uint256 private _burnCounter;

    ////-------owner batch
    mapping(address => uint256) private _ownerStartToken;

    /**
     * @dev this token does not need _allTokens & _allTokensIndex they both handeled virtually
     */

    ////////-------------------------

    constructor(
        address creator,
        uint256 batch,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        _preOwner = creator;
        super._beforeTokenTransfer(address(0), creator, 0, batch);
        uint256 start = 0;
        uint256 end = 0;

        // while (start < batch) {
        //     end = (start + 5000) < batch ? start + 5000 : batch;
        //     emit ConsecutiveTransfer(start, end -1, address(0), creator);
        //     start += 5000;
        // }
        _maxSupply += batch;
    }

    // ---
    // constructor(
    //     string memory name_,
    //     string memory symbol_,
    //     uint256 maxSupply_,
    //     address preOwner_
    // ) ERC721FancyMint(name_, symbol_, maxSupply_, preOwner_) {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _ownerOf(uint256 tokenId)
        internal
        view
        virtual
        override
        returns (address)
    {
        if (_sequentialBurn.get(tokenId)) {
            return address(0);
        }
        address owner = super._ownerOf(tokenId);

        if (owner == address(0) && tokenId < _maxSupply) {
            return _preOwner;
        }
        // return _sequentialBurn.get(tokenId) ? address(0) : owner;
        return owner;
    }

    // bad remove it
    function getBurn(uint256 tokenId) public view returns (string memory) {
        if (_sequentialBurn.get(tokenId)) {
            return "true";
        } else {
            return "false";
        }
    }

    //new
    function ownerTokenByIndex(address _owner, uint256 _index)
        internal
        view
        returns (uint256)
    {
        //maybe remove it to tokenOfownerByIndex
        require(
            _index < ERC721.balanceOf(_owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        uint256 virtual_tokenId = _ownedTokens[_owner][_index];

        if (virtual_tokenId == 0) {
            return _index; //+ _ownerStartToken[_owner];
        } else {
            return virtual_tokenId - 1;
        }
    }

    function ownerIndexByToken(address _owner, uint256 _tokenId)
        internal
        view
        returns (uint256)
    {
        // uint256 virtual_index = _ownedTokensIndex[_owner][_tokenId];
        uint256 virtual_index = _ownedTokensIndex[_tokenId];
        if (virtual_index == 0) {
            return _tokenId - _ownerStartToken[_owner];
        } else {
            return virtual_index - 1;
        }
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return ownerTokenByIndex(owner, index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _maxSupply + _mintCounter - _burnCounter;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    /**
     * @dev handling tokens index virtualy
     */
    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721CE.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        uint256 virtualIndex = _allIndexToTokenId[index];
        if (virtualIndex == 0) {
            return index;
        }
        return virtualIndex - 1;
    }

    ////-----indexByToken
    function indexByToken(uint256 tokenId) private view returns (uint256) {
        // require(
        //     index < ERC721CE.totalSupply(),
        //     "ERC721Enumerable: global index out of bounds"
        // );
        uint256 virtualIndex = _allTokenToIndex[tokenId];
        if (virtualIndex == 0) {
            return tokenId;
        }
        return virtualIndex - 1;
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        require(
            Address.isContract(address(this)),
            "ERC721ConsecutiveEnumerable: can't mint during construction"
        );
        super._mint(to, tokenId);
        // if (tokenId < _maxSupply) {
        //     _burnCounter -= 1;
        //     _sequentialBurn.unset(tokenId);
        // } else {
        //     _mintCounter += 1;
        // }
    }

    /**
     *This Token does NOT includes mintingand burning.
     *
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, it reverts it has no minting function
     * - When `to` is zero, ``from``'s it reverts it has no burn function
     * - `from` and 'to' cannot be the zero address at the same time.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    /** @dev it's my proposal
     save me */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        //caution 0 or 1?
        if (batchSize > 1) {
            require(
                !Address.isContract(address(this)),
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
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
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
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        // uint256 tokenIndex = _ownedTokensIndex[tokenId];
        uint256 tokenIndex = ownerIndexByToken(from, tokenId);

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            // uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            uint256 lastTokenId = ownerTokenByIndex(from, lastTokenIndex); //[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId + 1; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex + 1; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**@dev my proposal
     * since before _beforeTokenTransfer revert if to = address(0) ,and this token is has no burn function, _removeTokenFromAllTokensEnumeration function has been removed
     */

    function _addTokenToAllTokensEnumeration(uint256 tokenId) internal virtual {
        uint256 _index = totalSupply();
        _allIndexToTokenId[_index] = tokenId + 1;
        _allTokenToIndex[tokenId] = _index + 1;
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId)
        internal
        virtual
    {
        // revert("not burnable");
        uint256 lastIndex = totalSupply() - 1;
        // uint256 tokenIndex = tokenByIndex(tokenId);
        uint256 tokenIndex = indexByToken(tokenId);

        if (lastIndex != tokenIndex) {
            uint256 lastTokenId = tokenByIndex(lastIndex);
            _allIndexToTokenId[tokenIndex] = lastTokenId + 1;
            _allTokenToIndex[lastTokenId] = tokenIndex + 1;
        }
        delete _allIndexToTokenId[lastIndex];
        delete _allTokenToIndex[tokenId];
    }

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
            if (firstTokenId < _maxSupply) {
                _sequentialBurn.set(firstTokenId);
                _burnCounter += 1;
            } else {
                _mintCounter -= 1;
            }
        }

        if (from == address(0)) {
            if (firstTokenId < _maxSupply) {
                _burnCounter -= 1;
                _sequentialBurn.unset(firstTokenId);
            } else {
                _mintCounter += 1;
            }
        }

        super._afterTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
