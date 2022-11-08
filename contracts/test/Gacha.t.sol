// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ERC20PermitUtil, ERC721PermitUtil} from "./SigUtils.t.sol";

import {BK20} from "../BK20.sol";
import {BKNFT} from "../BK721.sol";
import {Gacha} from "../Gacha.sol";
import {Treasury} from "../Treasury.sol";
import {CommandGate} from "../CommandGate.sol";
import {Roles, Authority} from "../Authority.sol";

import "oz-custom/contracts/oz/token/ERC20/extensions/draft-IERC20Permit.sol";

contract GachaTest is Test {
    address public admin;
    address public gambler;

    uint256 gamblerPk;

    BK20 public pmt1 = new BK20();
    BK20 public pmt2 = new BK20();
    address[] public supportedPayments = [
        address(0),
        address(pmt1),
        address(pmt2)
    ];

    ERC20PermitUtil public erc20PermitUtil;

    BKNFT public nft = new BKNFT();
    uint256 public id;

    Gacha public gacha = new Gacha();
    CommandGate public commandGate;
    Treasury public treasury = new Treasury();
    Authority public authority = new Authority();

    constructor() {
        admin = makeAddr("admin");
        (gambler, gamblerPk) = makeAddrAndKey("gambler");

        vm.startPrank(admin, admin);

        authority.init();
        treasury.init(authority);
        treasury.updatePayments(supportedPayments);
        uint256[] memory prices = new uint256[](supportedPayments.length);
        prices[0] = 1 ether;
        prices[1] = 2 ether;
        prices[2] = 3 ether;
        treasury.updatePrices(supportedPayments, prices);

        pmt1.init(authority, treasury, "PaymentToken", "PMT", 18);
        pmt1.mint(gambler, 1_000_000);
        erc20PermitUtil = new ERC20PermitUtil(pmt1.DOMAIN_SEPARATOR());

        nft.init("A", "", "", 0, pmt1, authority, treasury);
        id = nft.mint(gambler, 0);

        gacha.init(authority, treasury);
        uint96[] memory unitPrices = new uint96[](3);
        unitPrices[0] = 1;
        unitPrices[1] = 2;
        address[] memory payments = new address[](3);
        payments[0] = address(0);
        payments[1] = supportedPayments[1];
        payments[2] = address(nft);
        gacha.updateTicketPrice(1, payments, unitPrices);

        commandGate = new CommandGate(address(treasury), authority);
        commandGate.whitelistAddress(address(gacha));

        vm.stopPrank();
    }

    function setUp() public {
        hoax(gambler, 1_000_000 ether);
    }

    function testValidRedeemNative() public {
        bytes memory callData = abi.encode(1432, 1);
        vm.startPrank(gambler, gambler);
        commandGate.depositNativeTokenWithCommand{value: 1 ether}(
            address(gacha),
            gacha.redeemTicket.selector,
            callData
        );

        vm.stopPrank();
    }

    function testValidRedeemERC20() public {
        bytes memory callData = abi.encode(1432, 1);

        ERC20PermitUtil.Permit memory permit = ERC20PermitUtil.Permit({
            owner: gambler,
            spender: address(commandGate),
            value: 4 ether,
            nonce: 0,
            deadline: 1 days
        });

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            gamblerPk,
            erc20PermitUtil.getTypedDataHash(permit)
        );

        vm.startPrank(gambler, gambler);

        commandGate.depositERC20WithCommand(
            IERC20Permit(address(pmt1)),
            permit.value,
            permit.deadline,
            v,
            r,
            s,
            gacha.redeemTicket.selector,
            address(gacha),
            callData
        );
    }

    function testValidRedeemERC721() public {
        bytes memory callData = abi.encode(
            address(gacha),
            gacha.redeemTicket.selector,
            abi.encode(1432, 1)
        );

        vm.startPrank(gambler, gambler);

        nft.safeTransferFrom(gambler, address(commandGate), id, callData);

        vm.stopPrank();
    }
}