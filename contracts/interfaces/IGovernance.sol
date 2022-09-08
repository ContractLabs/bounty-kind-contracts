// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external/access/IAccessControlEnumerable.sol";

interface IGovernance is IAccessControlEnumerable {
    event TreasuryUpdated(address indexed from, address indexed to);
    event VerifierUpdated(address indexed from, address indexed to);
    event MultiPaymentRegistered(address[] indexed tokens);
    event PaymentUpdated(address indexed token, bool indexed isSet);

    function grantRoleProxy(address proxy_) external;

    function updateTreasury(address treasury_) external;

    function updateVerifier(address verifier_) external;

    function updatePaymentToken(address token_, bool isSet_) external;

    function registerTokens(address[] calldata tokens_) external;

    function grantRoleMulti(bytes32 role_, address[] calldata accounts_)
        external;

    function getRoleMulti(bytes32 role_)
        external
        view
        returns (address[] memory);

    function verifier() external view returns (address);

    function treasury() external view returns (address);

    function acceptedPayment(address token_) external view returns (bool);
}
