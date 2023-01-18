// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/IERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/IERC721Receiver.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Address.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Context.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Strings.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/introspection/ERC165.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/access/Ownable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721ETest is ERC721Enumerable {
    constructor() ERC721("test", "t") {}

    function mint(uint256 numberOfTokens) public {
        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();

            _safeMint(msg.sender, mintIndex);
        }
    }

    // function singleMint() public {
    //     _mint(msg.sender, totalSupply());
    // }

    function singleMintArbi(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }

    function singleBurn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
