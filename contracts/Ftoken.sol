// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721CEBurnable.sol";
import {Base64} from "OpenZeppelin/openzeppelin-contracts@4.7.0/contracts/utils/Base64.sol";

contract FT is ERC721CEBurn {
    using Strings for uint256;

    string private name_ = "FFR Project : ffff";
    string private symbol_ = "FPP";
    uint256 private maxSupply_ = 19;
    address private preOwner_ = 0x66aB6D9362d4F35596279692F0251Db635165871;

    //
    bool private notFinialized = true;

    constructor() ERC721CE(preOwner_, maxSupply_, name_, symbol_) {}

    function singleMint() public {
        _mint(msg.sender, totalSupply());
    }

    function singleMintArbi(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }

    // in case the marketplace need this
    // function emitHandlerSingle() public onlyOwner {
    //     require(notFinialized, "finalized!0");
    //     emit ConsecutiveTransfer(0, maxSupply_ - 1, address(0), preOwner_);
    // }

    // function finalizer() public onlyOwner {
    //     require(notFinialized, "finalized!1");
    //     notFinialized = false;
    // }

    // function get_color(uint256 colorNum) internal view {
    //     return colors[colorNum * 6:(colorNum + 1) * 6];
    // }

    function constructTokenURI(uint256 id)
        internal
        view
        returns (string memory)
    {
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

    function tokenURI(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(id), "token does not exist!");
        return constructTokenURI(id);
    }
}
