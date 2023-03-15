import { expect } from "chai";
import { ethers } from "hardhat";
import { TypedDataUtils } from "ethers-eip712";

describe("InstadappTargetAuth", function () {
  const hardhatChainId = 31337;

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
        chainId: hardhatChainId,
        verifyingContract: await instance.address,
      },
      message: {
        _targetNames: ["target1", "target2"],
        _datas: [ethers.utils.hexlify([1, 2, 3]), ethers.utils.hexlify([4, 5, 6])],
        _origin: await otherAccount.getAddress(),
      },
    };

    return { instance, owner, otherAccount, typedData };
  }

  describe("#verify", function () {
    it("Should work", async function () {
      const { instance, owner, otherAccount, typedData } = await deploy();

      const wallet = ethers.Wallet.createRandom();

      const digest = TypedDataUtils.encodeDigest(typedData);
      const signature = await wallet.signMessage(ethers.utils.arrayify(digest));
      console.log(`signature: ${signature}`);

      const { r, s, v } = ethers.utils.splitSignature(signature);
      console.log(r, s, v);

      const sender = await wallet.getAddress();
      console.log(`sender: ${sender}`);

      const verified = await instance.connect(otherAccount).verify(typedData.message, sender, v, r, s);
      expect(verified).to.be.true;
    });
  });
});
