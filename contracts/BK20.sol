// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IBK20} from "./interfaces/IBK20.sol";

import {
    UUPSUpgradeable
} from "oz-custom/contracts/oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {ErrorHandler} from "oz-custom/contracts/libraries/ErrorHandler.sol";

import {
    AccessControlEnumerableUpgradeable
} from "oz-custom/contracts/oz-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

import {
    ERC20Upgradeable,
    ERC20PermitUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

import {
    ERC20BurnableUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";

import {
    PausableUpgradeable,
    ERC20PausableUpgradeable
} from "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";

import {
    TransferableUpgradeable
} from "oz-custom/contracts/internal-upgradeable/TransferableUpgradeable.sol";
import {
    ProxyCheckerUpgradeable
} from "oz-custom/contracts/internal-upgradeable/ProxyCheckerUpgradeable.sol";
import {
    BlacklistableUpgradeable
} from "oz-custom/contracts/internal-upgradeable/BlacklistableUpgradeable.sol";

contract BK20 is
    IBK20,
    UUPSUpgradeable,
    ERC20PermitUpgradeable,
    TransferableUpgradeable,
    ProxyCheckerUpgradeable,
    BlacklistableUpgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    AccessControlEnumerableUpgradeable
{
    using ErrorHandler for bool;

    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    bytes32 public constant MINTER_ROLE =
        0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;
    bytes32 public constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;
    bytes32 public constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;

    function initialize(
        address admin_,
        uint256 initialSupply_,
        string calldata name_,
        string calldata symbol_
    ) external initializer {
        __UUPSUpgradeable_init();
        __ERC20Permit_init(name_);
        __ERC20_init_unchained(name_, symbol_);
        address operator = _msgSender();

        bytes32 pauserRole = PAUSER_ROLE;
        bytes32 minterRole = MINTER_ROLE;
        bytes32 operatorRole = OPERATOR_ROLE;
        bytes32 upgraderRole = UPGRADER_ROLE;

        _grantRole(pauserRole, operator);
        _grantRole(minterRole, operator);
        _grantRole(operatorRole, operator);
        _grantRole(upgraderRole, operator);

        _grantRole(pauserRole, admin_);
        _grantRole(minterRole, admin_);
        _grantRole(operatorRole, admin_);
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);

        _mint(admin_, initialSupply_ * 1 ether);
    }

    function setUserStatus(
        address account_,
        bool status_
    ) external onlyRole(OPERATOR_ROLE) {
        _setUserStatus(account_, status_);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @inheritdoc IBK20
    function mint(address to_, uint256 amount_) external onlyRole(MINTER_ROLE) {
        _mint(to_, amount_);
    }

    /// @inheritdoc IBK20
    //  @dev minimal function to recover lost funds
    function execute(
        address target_,
        uint256 value_,
        bytes calldata calldata_
    ) external whenPaused onlyRole(OPERATOR_ROLE) {
        (bool success, bytes memory returnOrRevertData) = target_.call{
            value: value_
        }(calldata_);
        success.handleRevertIfNotSuccess(returnOrRevertData);

        emit Executed(
            _msgSender(),
            target_,
            value_,
            calldata_,
            returnOrRevertData
        );
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        if (
            isBlacklisted(to_) ||
            isBlacklisted(from_) ||
            isBlacklisted(_msgSender())
        ) revert BountyKindsERC20__Blacklisted();

        super._beforeTokenTransfer(from_, to_, amount_);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControlEnumerableUpgradeable, ERC20Upgradeable)
        returns (bool)
    {}

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyRole(UPGRADER_ROLE) {}

    uint256[50] private __gap;
}
