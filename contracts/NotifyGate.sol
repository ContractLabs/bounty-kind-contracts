// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/internal/FundForwarder.sol";

import "./interfaces/INotifyGate.sol";

contract NotifyGate is INotifyGate, FundForwarder, ERC721TokenReceiver {
    constructor(address vault_) payable FundForwarder(vault_) {}

    function notifyWithNative(bytes calldata message_) external payable {
        _safeNativeTransfer(vault, msg.value);
        emit Notified(_msgSender(), message_, address(0), msg.value, "");
    }

    function onERC721Received(
        address from_,
        address,
        uint256 tokenId_,
        bytes calldata message_
    ) external override returns (bytes4) {
        address nft = _msgSender();
        IERC721(nft).safeTransferFrom(address(this), vault, tokenId_);

        emit Notified(from_, message_, nft, tokenId_, "");

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
    ) external {
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
        _safeERC20TransferFrom(token_, user, vault, value_);

        emit Notified(user, message_, address(token_), value_, "");
    }
}
