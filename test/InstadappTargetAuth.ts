import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("InstadappTargetAuth", function () {
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const contract = await ethers.getContractFactory("InstadappTargetAuth");
    const instance = await contract.deploy();

    return { instance, owner, otherAccount };
  }

  describe("#verify", function () {
    it("Should work", async function () {});
  });
});
