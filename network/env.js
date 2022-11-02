const dotenv = require("dotenv");
const fs = require("fs");

function readNetworkEnv(network) {
  const networkName = network.name;
  dotenv.config({ path: `./network/.env.${networkName}` });
}

const KEYS = [
  "YU",
  "FFE",
  "BOUNTYKIND_PACKAGE",
  "NFT_CHARACTER",
  "NFT_ITEM",
  "NFT_SAPPHIRE",
  "NFT_METABLOCK",
  "MARKET",
  "MARKET_SUB",
  "GACHA",
  "EXCHANGE",
  "FIAT",
];

function writeNetworkEnv(key, value, network) {
  try {
    if (!KEYS.includes(key)) {
      throw new Error(`'${key}' is not exist`);
    }
    let data = "";
    KEYS.forEach(_key => {
      data += `${_key}=${(key !== _key ? process.env[_key] : value) ?? ""}\n`;
    });
    fs.writeFileSync(`./network/.env.${network.name}`, data);
  } catch (e) {
    console.error(e);
  }
}

module.exports = {
  readNetworkEnv,
  writeNetworkEnv,
};
