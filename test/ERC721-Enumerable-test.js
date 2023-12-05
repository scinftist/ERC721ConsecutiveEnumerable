const { ethers } = require("hardhat");
const { assert, expect } = require("chai");
// const fs = require("fs");
// const exp = require("constants");
let _verbose = false;

describe("testing ERC721 Enumerable Interfaces", () => {
  let erc721CE;
  let erc721E;
  let accList;
  beforeEach(async function () {
    accList = await ethers.getSigners();
    erc721CE = await ethers.deployContract("ERC721CE_Test");
    if (_verbose)
      console.log(`deployed address is ${await erc721CE.getAddress()}`);
    erc721E = await ethers.deployContract("ERC721ETest");
    if (_verbose)
      console.log(`deployed address is ${await erc721E.getAddress()}`);

    for (i = 0; i < 3; i++) {
      await erc721E.connect(accList[i]).mint(50);
    }
  });

  it("initial status are set", async () => {
    let ll = [50, 50, 50];
    for (i = 0; i < 3; i++) {
      // console.log(`${await accList[i].getAddress()}`)
      await expect(
        await erc721CE.balanceOf(await accList[i].getAddress())
      ).to.be.equal(ll[i]);
      await expect(
        await erc721E.balanceOf(await accList[i].getAddress())
      ).to.be.equal(ll[i]);
    }
  });
  it("initial status are set: totalSupply()", async () => {
    let ll = [50, 50, 50];
    for (i = 0; i < 3; i++) {
      // console.log(`${await accList[i].getAddress()}`)
      await expect(await erc721CE.totalSupply()).to.be.equal(
        await erc721E.totalSupply()
      );
    }
  });
});

function getRandomIntInclusive(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1) + min); // The maximum is inclusive and the minimum is inclusive
}
