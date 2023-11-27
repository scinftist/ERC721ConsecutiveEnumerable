const { ethers } = require("hardhat");
const { assert, expect } = require("chai");
// const fs = require("fs");
// const exp = require("constants");
let _verbose = false;

describe("testing ERC721 Interfaces", () => {
  let erc721CE, ERC721ConsecutiveEnumerable;
  let accList;
  beforeEach(async function () {
    accList = await ethers.getSigners();
    erc721CE = await ethers.deployContract("ERC721CE_Test");
    console.log(`deployed address is ${await erc721CE.getAddress()}`);
  });
  it("erc721", async () => {
    console.log(`pas`);
  });
});
