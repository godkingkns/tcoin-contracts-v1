require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      viaIR: true,
    }
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      forking: {
        url: `https://eth-mainnet.g.alchemy.com/v2/scS7rThd70YD61xEU80rJAZnQArQ36Dw`,
        blockNumber: 19413810
      }
    }
  }
};
