import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  defaultNetwork: "hardhat",
  networks: {
    mainnet: {
      chainId: 1,
      url: "https://cloudflare-eth.com",
    },
    goerli: {
      chainId: 5,
      url: "https://goerli.infura.io/v3/7672e2bf7cbe427e8cd25b0f1dde65cf",
    },
    optimism: {
      chainId: 10,
      url: "https://mainnet.optimism.io",
    },
  },
};

export default config;
