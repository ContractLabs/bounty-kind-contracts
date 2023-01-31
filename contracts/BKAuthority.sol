// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BKTreasury} from "./BKTreasury.sol";
import {
    Create2Deployer
} from "oz-custom/contracts/internal/DeterministicDeployer.sol";
import {
    AuthorityUpgradeable
} from "oz-custom/contracts/presets-upgradeable/AuthorityUpgradeable.sol";

contract BKAuthority is Create2Deployer, AuthorityUpgradeable {
    function initialize(
        address admin_,
        address[] calldata operators_,
        bytes32[] calldata roles_
    ) external initializer {
        __Authority__init(admin_, operators_, roles_);
    }

    function _deployDefaultTreasury(
        address admin_,
        bytes memory
    ) internal override onlyInitializing returns (address) {
        return
            _deploy(
                address(this).balance,
                keccak256(abi.encode(address(this), VERSION)),
                abi.encodePacked(
                    type(BKTreasury).creationCode,
                    abi.encode(admin_, "BKGlobalTreasury")
                )
            );
    }

    uint256[50] private __gap;
}
