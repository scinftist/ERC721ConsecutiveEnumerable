// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./ERC721CE.sol";

abstract contract ERC721CEBurn is ERC721CE {
    // virtual +1 -1 ;
    mapping(uint256 => uint256) private _Indices;

    // mapping(uint256 => bool) private _tokenBurned;
    // uint256 private _totalBurned;

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
        uint256 virtualIndex = _Indices[index];
        if (virtualIndex == 0) {
            return index;
        }
        return virtualIndex - 1;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId)
        internal
        virtual
        override
    {
        uint256 _index = totalSupply();
        _Indices[_index] = tokenId + 1;
        // if (_tokenBurned[tokenId]) {
        //     _totalBurned -= 1;
        // }
        // delete _tokenBurned[tokenId];
    }

    // function _removeTokenFromAllTokensEnumeration(uint256 tokenId)
    //     internal
    //     virtual
    //     override
    // {
    //     uint256 lastIndex = totalSupplly() - 1;
    //     uint256 tokenIndex = tokenByIndex(tokenId);

    //     if (lastIndex != tokenIndex) {
    //         uint256 lastTokenId = tokenByIndex(lastIndex);
    //         _Indices[tokenIndex] = lastTokenId + 1;
    //     }
    //     delete _Indices[lastIndex];
    // }

    // function _ownerOf(tokenId) internal virtual override returns (address) {
    //     if (_tokenBurned[tokenId]) {
    //         return address(0);
    //     }
    //     super._ownerOf(tokenId);
    // }

    // function _burn(tokenId) internal virtual override {
    //     super._burn(tokenId);
    //     _tokenBurned[tokenId] = true;
    //     _totalBurned += 1;
    // }

    // function totalSupply() public view virtual override returns (uint256) {
    //     return _maxSupply - _totalBurned;
    // }
}
