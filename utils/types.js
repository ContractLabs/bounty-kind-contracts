const { isAddress } = require("ethers/lib/utils");
const { ERRORS } = require("hardhat/internal/core/errors-list");
const { HardhatError } = require("hardhat/internal/core/errors");
const { isTxHash } = require("./utils");

const address = {
  name: "address",
  parse: (argName, strValue) => strValue,
  validate: (argName, argumentValue) => {
    if (!isAddress(argumentValue)) {
      throw new HardhatError(ERRORS.ARGUMENTS.INVALID_VALUE_FOR_TYPE, {
        value: argumentValue,
        name: argName,
        type: address.name,
      });
    }
  },
};

const arrayAddress = {
  name: "array-address",
  parse: (argName, strValue) => strValue.split(","),
  validate: (argName, argumentValue) => {
    let addressList = argumentValue.split(",");

    for (let i = 0; i < addressList.length; i++) {
      if (!isAddress(addressList[i])) {
        throw new HardhatError(ERRORS.ARGUMENTS.INVALID_VALUE_FOR_TYPE, {
          value: addressList[i],
          name: argName,
          type: address.name,
        });
      }
    }
  },
};

const txHash = {
  name: "tx-hash",
  parse: (argName, strValue) => strValue,
  validate: (argName, argumentValue) => {
    if (!isTxHash(argumentValue)) {
      throw new HardhatError(ERRORS.ARGUMENTS.INVALID_VALUE_FOR_TYPE, {
        value: argumentValue,
        name: argName,
        type: txHash.name,
      });
    }
  },
};

const arrayTxHash = {
  name: "array-tx-hash",
  parse: (argName, strValue) => strValue.split(","),
  validate: (argName, argumentValue) => {
    let txHashList = argumentValue.split(",");

    for (let i = 0; i < txHashList.length; i++) {
      if (!isTxHash(txHashList[i])) {
        throw new HardhatError(ERRORS.ARGUMENTS.INVALID_VALUE_FOR_TYPE, {
          value: txHashList[i],
          name: argName,
          type: arrayTxHash.name,
        });
      }
    }
  },
};

const arrayInt = {
  name: "array-int",
  parse: (argName, strValue) => strValue.split(",").map(num => Number(num)),
  validate: (argName, argumentValue) => {
    const intList = argumentValue.split(",");
    for (let i = 0; i < intList.length; i++) {
      const isInt = Number.isInteger(intList[i]);
      if (!isInt) {
        throw new HardhatError(ERRORS.ARGUMENTS.INVALID_VALUE_FOR_TYPE, {
          value: intList[i],
          name: argName,
          type: "int",
        });
      }
    }
  },
};

const arrayFloat = {
  name: "array-float",
  parse: (argName, strValue) => strValue.split(",").map(num => Number(num)),
  validate: (argName, argumentValue) => {
    const numberList = argumentValue.split(",");
    for (let i = 0; i < intList.length; i++) {
      const isFloatOrInteger = typeof value === "number" && !isNaN(value);
      if (!isFloatOrInteger) {
        throw new HardhatError(ERRORS.ARGUMENTS.INVALID_VALUE_FOR_TYPE, {
          value: numberList[i],
          name: argName,
          type: "float",
        });
      }
    }
  },
};

module.exports = {
  address,
  arrayAddress,
  txHash,
  arrayTxHash,
  arrayInt,
  arrayFloat,
};
