const { convertNumberToHex } = require("./utils");

const CHAIN_ID = {
  Bacoor_Testnet: 7042022,
  Wraptag_Testnet: 14042022,

  // testnet
  TomoChain_Testnet: 89,
  Polygon_Testnet: 80001,
  Bsc_Testnet: 97,
  Rinkeby_Testnet: 4,

  // mainnet
  TomoChain_Mainnet: 88,
  Polygon_Mainnet: 137,
  Bsc_Mainnet: 56,
  Ethereum_Mainnet: 1,
};

const RPCs = {
  // testnet
  [CHAIN_ID.TomoChain_Testnet]: {
    chainName: "TomoChain Testnet",
    chainId: convertNumberToHex(CHAIN_ID.TomoChain_Testnet),
    rpcUrls: ["https://rpc.testnet.tomochain.com"],
    blockExplorerUrls: ["https://testnet.tomoscan.io"],
    nativeCurrency: {
      name: "TOMO",
      symbol: "TOMO",
      decimals: 18,
    },
  },
  [CHAIN_ID.Polygon_Testnet]: {
    chainName: "Mumbai Testnet",
    chainId: convertNumberToHex(CHAIN_ID.Polygon_Testnet),
    rpcUrls: ["https://rpc-mumbai.matic.today"],
    blockExplorerUrls: ["https://mumbai.polygonscan.com"],
    nativeCurrency: {
      name: "MATIC",
      symbol: "MATIC",
      decimals: 18,
    },
  },
  [CHAIN_ID.Bsc_Testnet]: {
    chainName: "BSC Testnet",
    chainId: convertNumberToHex(CHAIN_ID.Bsc_Testnet),
    rpcUrls: ["https://data-seed-prebsc-1-s1.binance.org:8545"],
    blockExplorerUrls: ["https://testnet.bscscan.com"],
    nativeCurrency: {
      name: "TBNB",
      symbol: "TBNB",
      decimals: 18,
    },
  },
  [CHAIN_ID.Rinkeby_Testnet]: {
    chainName: "Rinkeby Testnet",
    chainId: convertNumberToHex(CHAIN_ID.Rinkeby_Testnet),
    rpcUrls: ["https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161"],
    blockExplorerUrls: ["https://rinkeby.etherscan.io"],
    nativeCurrency: {
      name: "ETH",
      symbol: "ETH",
      decimals: 18,
    },
  },

  // mainnet
  [CHAIN_ID.TomoChain_Mainnet]: {
    chainName: "TomoChain Mainnet",
    chainId: convertNumberToHex(CHAIN_ID.TomoChain_Mainnet),
    rpcUrls: ["https://rpc.tomochain.com"],
    blockExplorerUrls: ["https://tomoscan.io"],
    nativeCurrency: {
      name: "TOMO",
      symbol: "TOMO",
      decimals: 18,
    },
  },
  [CHAIN_ID.Polygon_Mainnet]: {
    chainName: "Matic Mainnet",
    chainId: convertNumberToHex(CHAIN_ID.Polygon_Mainnet),
    rpcUrls: ["https://polygon-rpc.com"],
    blockExplorerUrls: ["https://polygonscan.com"],
    nativeCurrency: {
      name: "MATIC",
      symbol: "MATIC",
      decimals: 18,
    },
  },
  [CHAIN_ID.Bsc_Mainnet]: {
    chainName: "BSC Mainnet",
    chainId: convertNumberToHex(CHAIN_ID.Bsc_Mainnet),
    rpcUrls: ["https://bsc-dataseed.binance.org"],
    blockExplorerUrls: ["https://bscscan.com"],
    nativeCurrency: {
      name: "BNB",
      symbol: "BNB",
      decimals: 18,
    },
  },
  [CHAIN_ID.Ethereum_Mainnet]: {
    chainName: "Ethereum Mainnet",
    chainId: convertNumberToHex(CHAIN_ID.Ethereum_Mainnet),
    rpcUrls: ["https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161"],
    blockExplorerUrls: ["https://etherscan.io"],
    nativeCurrency: {
      name: "ETH",
      symbol: "ETH",
      decimals: 18,
    },
  },
};

const ADDRESS_ERC21_ISSUER = {
  [CHAIN_ID.TomoChain_Testnet]: "0x0E2C88753131CE01c7551B726b28BFD04e44003F",
  [CHAIN_ID.TomoChain_Mainnet]: "0x8c0faeb5C6bEd2129b8674F262Fd45c4e9468bee",
};

const MULTI_TRANSFER_ADDRESS = {
  // [CHAIN_ID.TomoChain_Testnet]: '',
  // [CHAIN_ID.Polygon_Testnet]: '',
  // [CHAIN_ID.Bsc_Testnet]: '',
  // [CHAIN_ID.Rinkeby_Testnet]: '',
  // [CHAIN_ID.TomoChain_Mainnet]: '',
  // [CHAIN_ID.Polygon_Mainnet]: '',
  // [CHAIN_ID.Bsc_Mainnet]: '',
  // [CHAIN_ID.Ethereum_Mainnet]: '',
};

module.exports = {
  CHAIN_ID,
  ADDRESS_ERC21_ISSUER,
  MULTI_TRANSFER_ADDRESS,
  RPCs,
};
