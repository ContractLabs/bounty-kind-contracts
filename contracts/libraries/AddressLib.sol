// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library AddressLib {
    function fromFirst20Bytes(bytes32 bytesValue)
        internal
        pure
        returns (address)
    {
        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue)
        internal
        pure
        returns (bytes32)
    {
        return bytes32(bytes20(addressValue));
    }

    function fromFirst160Bits(uint256 uintValue)
        internal
        pure
        returns (address)
    {
        return address(uint160(uintValue));
    }

    function fillLast96Bits(address addressValue)
        internal
        pure
        returns (uint256)
    {
        return uint256(uint160(addressValue));
    }

    function fromLast160Bits(uint256 uintValue)
        internal
        pure
        returns (address)
    {
        unchecked {
            return fromFirst160Bits(uintValue >> 0x60);
        }
    }

    function fillFirst96Bits(address addressValue)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return uint256(uint160(addressValue)) << 96;
        }
    }
}
