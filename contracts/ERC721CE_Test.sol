// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721ConsecutiveEnumerable.sol";
import {Base64} from "../openzepplin-contracts/utils/Base64.sol";

// import "./ERC721CE.sol";
// import {Base64} from "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Base64.sol";

contract CETest is ERC721ConsecutiveEnumerable {
    using Strings for uint256;

    string private name_ = "FFR Project : ffff";
    string private symbol_ = "FPP";
    // uint256 private maxSupply_ = 50;
    // address private preOwner_ = 0x66aB6D9362d4F35596279692F0251Db635165871;
    uint96[] private _amounts = [uint96(50), uint96(50), uint96(50)];
    //
    bool private notFinialized = true;

    constructor(
        address[] memory _receivers
    ) ERC721ConsecutiveEnumerable(name_, symbol_, _receivers, _amounts) {}

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
        require(_exists(id), "token does not exist!");
        return constructTokenURI(id);
    }
}
