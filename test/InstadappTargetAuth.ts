import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { TypedDataUtils } from "ethers-eip712";
import { mkAddress } from "@connext/nxtp-utils";

describe("InstadappTargetAuth", function () {
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();


    const dsaAddr = "0x8f7492DE823025b4CfaAB1D34c58963F2af5DEDA";

    const contract = await ethers.getContractFactory("InstadappTargetAuth");
    const instance = await contract.deploy(dsaAddr);
    await instance.deployed();

    const typedData = {
      types: {
        EIP712Domain: [
          { name: "name", type: "string" },
          { name: "version", type: "string" },
          { name: "chainId", type: "uint256" },
          { name: "verifyingContract", type: "address" },
        ],
        CastData: [
          { name: "_targetNames", type: "string[]" },
          { name: "_datas", type: "bytes[]" },
          { name: "_origin", type: "address" },
        ],
      },
      primaryType: "CastData" as const,
      domain: {
        name: "InstadappTargetAuth",
        version: "1",
        chainId: 1,
        verifyingContract: await instance.getAddress(),
      },
      message: {
        _targetNames: [""],
        _datas: [""],
        _origin: await otherAccount.getAddress(),
      },
    };

    return { instance, owner, otherAccount, typedData };
  }

  describe("#verify", function () {
    it("Should work", async function () {
      const { instance, owner, otherAccount, typedData } = await deploy();

      const digest = TypedDataUtils.encodeDigest(typedData);
      const digestHex = ethers.hexlify(digest);

      const wallet = ethers.Wallet.createRandom();
      const signature = wallet.signMessage(digest);


      const sender = await wallet.getAddress();

      console.log(signature)

      // instance.connect(otherAccount).verify(mockCastData, sender, );
    });
  });
});
