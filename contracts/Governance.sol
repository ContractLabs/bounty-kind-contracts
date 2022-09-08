// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external/access/AccessControlEnumerable.sol";

import "./utils/OnlyProxy.sol";

import "./interfaces/IOwnable.sol";
import "./interfaces/IGovernance.sol";

error Governance__Unauthorized();

contract Governance is IGovernance, OnlyProxy, AccessControlEnumerable {
    using AddressLib for address;
    using AddressLib for bytes32;
    using BitMaps for BitMaps.BitMap;

    bytes32 private _treasury;
    bytes32 private _verifier;

    BitMaps.BitMap private _acceptedPayments;

    ///@dev value is equal keccak256("VERIFIER_ROLE")
    bytes32 private constant _VERIFIER_ROLE =
        0x0ce23c3e399818cfee81a7ab0880f714e53d7672b08df0fa62f2843416e1ea09;

    ///@dev value is equal keccak256("PROXY_ROLE")
    bytes32 private constant _PROXY_ROLE =
        0x77d72916e966418e6dc58a19999ae9934bef3f749f1547cde0a86e809f19c89b;

    modifier onlyAdminOrSharedProxy() {
        __onlyAdminOrSharedProxy(_msgSender());
        _;
    }

    constructor(address treasury_, address verifier_) payable {
        __updateTreasury(treasury_);
        __updateVerifier(verifier_);
        _grantRole(_VERIFIER_ROLE, verifier_);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function grantRoleProxy(address proxy_) external override {
        address sender = _msgSender();
        if (!_isProxy(sender)) _checkRole(DEFAULT_ADMIN_ROLE, sender);
        else _checkRole(DEFAULT_ADMIN_ROLE, IOwnable(sender).owner());
        _grantRole(_PROXY_ROLE, proxy_);
    }

    function updateTreasury(address treasury_)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        emit TreasuryUpdated(_treasury.fromFirst20Bytes(), treasury_);
        __updateTreasury(treasury_);
    }

    function updateVerifier(address verifier_) external override {
        address sender = _msgSender();
        if (!hasRole(DEFAULT_ADMIN_ROLE, sender))
            _checkRole(_VERIFIER_ROLE, sender);
        emit VerifierUpdated(_verifier.fromFirst20Bytes(), verifier_);
        __updateVerifier(verifier_);
    }

    function updatePaymentToken(address token_, bool isSet_)
        external
        override
        onlyAdminOrSharedProxy
    {
        __updatePaymentToken(token_, isSet_);
        emit PaymentUpdated(token_, isSet_);
    }

    function registerTokens(address[] calldata tokens_)
        external
        override
        onlyAdminOrSharedProxy
    {
        uint256 length = tokens_.length;
        for (uint256 i; i < length; ) {
            __updatePaymentToken(tokens_[i], true);
            unchecked {
                ++i;
            }
        }
        emit MultiPaymentRegistered(tokens_);
    }

    function grantRole(bytes32 role_, address account_)
        public
        override(AccessControl, IAccessControl)
        onlyAdminOrSharedProxy
    {
        _grantRole(role_, account_);
    }

    function grantRoleMulti(bytes32 role_, address[] calldata accounts_)
        external
        override
        onlyAdminOrSharedProxy
    {
        uint256 length = accounts_.length;
        for (uint256 i; i < length; ) {
            _grantRole(role_, accounts_[i]);
            unchecked {
                ++i;
            }
        }
    }

    function getRoleMulti(bytes32 role_)
        external
        view
        override
        returns (address[] memory accounts)
    {
        uint256 length = getRoleMemberCount(role_);
        for (uint256 i; i < length; ) {
            accounts[i] = getRoleMember(role_, i);
            unchecked {
                ++i;
            }
        }
    }

    function verifier() external view override returns (address) {
        return _verifier.fromFirst20Bytes();
    }

    function treasury() external view override returns (address) {
        return _treasury.fromFirst20Bytes();
    }

    function acceptedPayment(address token_)
        external
        view
        override
        returns (bool)
    {
        return _acceptedPayments.get(token_.fillLast96Bits());
    }

    function __updateTreasury(address treasury_) private {
        _treasury = treasury_.fillLast12Bytes();
    }

    function __updatePaymentToken(address token_, bool isSet_) internal {
        _acceptedPayments.setTo(token_.fillLast96Bits(), isSet_);
    }

    function __updateVerifier(address verifier_) internal {
        _verifier = verifier_.fillLast12Bytes();
    }

    function __onlyAdminOrSharedProxy(address sender_) private view {
        if (!_isProxy(sender_)) _checkRole(DEFAULT_ADMIN_ROLE, sender_);
        else _checkRole(_PROXY_ROLE, sender_);
    }
}
