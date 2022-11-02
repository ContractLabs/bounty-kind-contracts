const { CHAIN_ID, RPCs } = require("./constants");

function isTomoChain(network) {
  const chainId = network.config.chainId;
  return [CHAIN_ID.TomoChain_Mainnet, CHAIN_ID.TomoChain_Testnet].includes(chainId);
}

function isPolygon(network) {
  const chainId = network.config.chainId;
  return [CHAIN_ID.Polygon_Mainnet, CHAIN_ID.Polygon_Testnet].includes(chainId);
}

function isBSC(network) {
  const chainId = network.config.chainId;
  return [CHAIN_ID.Bsc_Mainnet, CHAIN_ID.Bsc_Testnet].includes(chainId);
}

function isEthereum(network) {
  const chainId = network.config.chainId;
  return [CHAIN_ID.Ethereum_Mainnet, CHAIN_ID.Rinkeby_Testnet].includes(chainId);
}

function isLocalNetwork(network) {
  const chainId = network.config.chainId;
  return !Object.values(CHAIN_ID).includes(chainId);
}

function transactionPage(network, tx) {
  const chainId = network.config.chainId;
  return `${RPCs[chainId]?.blockExplorerUrls?.[0] ?? "."}/tx/${tx.transactionHash}`;
}

function tokenPage(network, address) {
  const chainId = network.config.chainId;
  return `${RPCs[chainId]?.blockExplorerUrls?.[0] ?? "."}/token/${address}`;
}

function addressPage(network, address) {
  const chainId = network.config.chainId;
  return `${RPCs[chainId]?.blockExplorerUrls?.[0] ?? "."}/address/${address}`;
}

module.exports = {
  isLocalNetwork,
  isTomoChain,
  isPolygon,
  isBSC,
  isEthereum,
  transactionPage,
  tokenPage,
  addressPage,
};
