require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-web3')
require('./tasks')
// // Account testnet
const accountsTestnet = require('./accounts/accounts.testnet.json')
const privateKeysTestnet = accountsTestnet.map(acc => acc.privateKey)

// // 100 Account 
const accounts = require('./accounts/accounts.json')
const privateKeys = accounts.map(acc => acc.privateKey)

// // Account mainnet
// const fs = require('fs')
// const accountsMainnet = fs.existsSync('./accounts/accounts.mainnet.json')
//   ? require('./accounts/accounts.mainnet.json')
//   : []
// const privateKeysMainnet = accountsMainnet.map(acc => acc.privateKey)



// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: 'bsc', // default hardhat
  networks: {
    hardhat: {
      // chainId: 31337,
    },
    // tomochain testnet
    tomo: {
      url: 'https://rpc.testnet.tomochain.com',
      chainId: 89,
      accounts: privateKeysTestnet,
      gasPrice: 250000000,
      gas: 2100000,
    },
    // mumbai polygon testnet
    mumbai: {
      url: 'https://rpc-mumbai.matic.today',
      chainId: 80001,
      accounts: privateKeysTestnet,
      gasPrice: 1999999997,
      gas: 2100000,
    },
    // bsc testnet
    bsc: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      chainId: 97,
      accounts: privateKeysTestnet,
      // accounts: privateKeys,
      gasPrice: 10000000000,
      gas: 2100000,
    },
    // eth testnet
    rinkeby: {
      url: 'https://rinkey.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
      chainId: 4,
      accounts: privateKeysTestnet,
      gasPrice: 8000000000,
      gas: 2100000,
    },
    // // tomochain mainnet
    // 'tomo-mainnet': {
    //   url: 'https://rpc.tomochain.com',
    //   chainId: 88,
    //   accounts: privateKeysMainnet,
    //   gasPrice: 250000000,
    //   gas: 2100000,
    // },
    // // polygon mainnet
    // polygon: {
    //   url: 'https://polygon-rpc.com',
    //   chainId: 137,
    //   accounts: privateKeysMainnet,
    //   gasPrice: 1999999997,
    //   gas: 2100000,
    // },
    // // bsc mainnet
    // 'bsc-mainnet': {
    //   url: 'https://bsc-dataseed.binance.org',
    //   chainId: 56,
    //   accounts: privateKeysMainnet,
    //   gasPrice: 10000000000,
    //   gas: 2100000,
    // },
    // // eth mainnet
    // ethereum: {
    //   url: 'https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
    //   chainId: 1,
    //   accounts: privateKeysMainnet,
    //   gasPrice: 8000000000,
    //   gas: 2100000,
    // },
  },
  solidity: {
    compilers: [
      {
        version: '0.4.26',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.15',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  paths: {
    // root: '.',
    // configFile: './hardhat.config.js',
    // sources: './contracts',
    // cache: './cache',
    // artifacts: './artifacts',
    tests: './tests', // default './test'
  }
}
