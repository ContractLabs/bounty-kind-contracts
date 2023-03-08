// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {
    Roles,
    AuthorityUpgradeable
} from "oz-custom/contracts/presets-upgradeable/AuthorityUpgradeable.sol";

import {
    IFundForwarderUpgradeable
} from "oz-custom/contracts/internal-upgradeable/interfaces/IFundForwarderUpgradeable.sol";

contract BKAuthority is AuthorityUpgradeable {
    function initialize(
        address admin_,
        bytes32[] calldata roles_,
        address[] calldata operators_
    ) external initializer {
        __BKAuthority_init_unchained();
        __Authority_init(admin_, "", roles_, operators_);
    }

    function __BKAuthority_init_unchained() internal onlyInitializing {
        _setRoleAdmin(Roles.MINTER_ROLE, Roles.OPERATOR_ROLE);
    }

    function safeRecoverHeader() public pure override returns (bytes memory) {
        /// @dev value is equal keccak256("SAFE_RECOVER_HEADER")
        return
            bytes.concat(
                bytes32(
                    0x556d79614195ebefcc31ab1ee514b9953934b87d25857902370689cbd29b49de
                )
            );
    }

    function safeTransferHeader() public pure override returns (bytes memory) {
        /// @dev value is equal keccak256("SAFE_TRANSFER")
        return
            bytes.concat(
                bytes32(
                    0xc9627ddb76e5ee80829319617b557cc79498bbbc5553d8c632749a7511825f5d
                )
            );
    }

    function _beforeRecover(
        bytes memory
    ) internal override onlyRole(Roles.OPERATOR_ROLE) whenPaused {}

    function _afterRecover(
        address,
        address,
        uint256,
        bytes memory
    ) internal override {}

    uint256[50] private __gap;
}
