// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./internal/BKFundForwarder.sol";

import "oz-custom/contracts/presets/base/Manager.sol";
import "oz-custom/contracts/oz/security/ReentrancyGuard.sol";

import "./interfaces/INotifyGate.sol";
import "oz-custom/contracts/internal/interfaces/IWithdrawable.sol";

contract NotifyGate is
    Manager,
    INotifyGate,
    ReentrancyGuard,
    BKFundForwarder,
    ERC721TokenReceiver
{
    constructor(
        IAuthority authority_,
        address vault_
    ) payable ReentrancyGuard() FundForwarder(vault_) Manager(authority_, 0) {}

    function changeVault(
        address vault_
    ) external override onlyRole(Roles.TREASURER_ROLE) {
        _changeVault(vault_);
    }

    function notifyWithNative(bytes calldata message_) external payable {
        _safeNativeTransfer(vault(), msg.value);
        emit Notified(_msgSender(), message_, address(0), msg.value);
    }

    function onERC721Received(
        address from_,
        address,
        uint256 tokenId_,
        bytes calldata message_
    ) external override returns (bytes4) {
        address nft = _msgSender();
        IERC721(nft).safeTransferFrom(
            address(this),
            vault(),
            tokenId_,
            safeTransferHeader()
        );

        emit Notified(from_, message_, nft, tokenId_);

        return this.onERC721Received.selector;
    }

    function notifyWithERC20(
        IERC20 token_,
        uint256 value_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes calldata message_
    ) external nonReentrant {
        address user = _msgSender();
        if (token_.allowance(user, address(this)) < value_) {
            IERC20Permit(address(token_)).permit(
                user,
                address(this),
                value_,
                deadline_,
                v,
                r,
                s
            );
        }

        address _vault = vault();

        _safeERC20TransferFrom(token_, user, _vault, value_);

        if (
            IWithdrawable(_vault).notifyERC20Transfer(
                address(token_),
                value_,
                safeTransferHeader()
            ) != IWithdrawable.notifyERC20Transfer.selector
        ) revert();

        emit Notified(user, message_, address(token_), value_);
    }

    function _afterRecover(
        address vault_,
        address token_,
        bytes memory value_
    ) internal override {
        IWithdrawable(vault_).notifyERC20Transfer(
            token_,
            abi.decode(value_, (uint256)),
            safeRecoverHeader()
        );
    }
}
