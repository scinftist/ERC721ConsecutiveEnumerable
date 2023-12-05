// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "contracts/ERC721ConsecutiveEnumerable/ERC721ConsecutiveEnumerable.sol";
// contracts/ERC721ConsecutiveEnumerable
// import "./ERC721ConsecutiveEnumerable/ERC721ConsecutiveEnumerable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

// import "./ERC721CE.sol";
// import {Base64} from "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Base64.sol";

contract ERC721CE_Test is ERC721ConsecutiveEnumerable {
    using Strings for uint256;

    string private name_ = "FFR Project : ffff";
    string private symbol_ = "FPP";
    // uint256 private maxSupply_ = 50;
    // address private preOwner_ = 0x66aB6D9362d4F35596279692F0251Db635165871;
    uint96[] private _amounts = [uint96(50), uint96(50), uint96(50)];
    address[] private _recivers = [
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
    ];
    //
    bool private notFinialized = true;

    constructor()
        ERC721ConsecutiveEnumerable(name_, symbol_, _recivers, _amounts)
    {}

    // function singleMint() public {
    //     _mint(msg.sender, totalSupply());
    // }

    function singleMintArbi(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }

    function singleBurn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function constructTokenURI(
        uint256 id
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '"image": "data:image/svg+xml;base64,',
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {
        _requireOwned(id);
        return constructTokenURI(id);
    }
}
