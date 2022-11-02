const { isHexString } = require("@ethersproject/bytes");

function convertNumberToHex(number, padding = 2) {
  var hex = Number(number).toString(16);
  while (hex.length < padding) {
    hex = `0${hex}`;
  }

  return `0x${hex}`;
}

function isTxHash(txHash) {
  if (typeof txHash !== "string") {
    return false;
  }
  if (txHash.match(/^(0x)?[0-9a-fA-F]{64}$/)) {
    if (txHash.substring(0, 2) !== "0x") {
      txHash = "0x" + txHash;
    }

    return isHexString(txHash, 32);
  }

  return false;
}

module.exports = {
  convertNumberToHex,
  isTxHash,
};
