// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {MockERC721} from "./mock/MockERC721.t.sol";
import {MockERC1155} from "./mock/MockERC1155.t.sol";

import {BKTreasury} from "../BKTreasury.sol";
import {BKAuthority} from "../BKAuthority.sol";
import {UniversalCommandGate} from "../UniversalCommandGate.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

interface ILogInput {
    function erc1155Log(
        address account_,
        address token,
        uint256 id,
        bytes calldata extraData,
        uint256 inputA,
        uint256 inputB,
        uint256 inputC
    ) external view;

    function erc1155BatchLog(
        address account_,
        address token_,
        uint256 id,
        bytes calldata extraData,
        uint256 inputA,
        uint256 inputB,
        uint256 inputC
    ) external view;
}

contract LogInput is ILogInput {
    function erc1155Log(
        address account_,
        address token,
        uint256 id,
        bytes calldata extraData,
        uint256 inputA,
        uint256 inputB,
        uint256 inputC
    ) external view {}

    function erc1155BatchLog(
        address account_,
        address token_,
        uint256 id,
        bytes calldata extraData,
        uint256 inputA,
        uint256 inputB,
        uint256 inputC
    ) external view {}
}

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract UniversalCommandGateTest is Test {
    struct Asset {
        address token;
        uint256 value;
        address account;
        uint256 deadline;
        bytes signature;
        bytes extraData;
    }

    struct Command {
        bytes4 fnSig;
        address target;
        address vault;
        bytes arguments;
    }

    address admin;
    address operator;

    MockERC721 nft;
    LogInput logInput;
    MockERC1155 semiNFT;
    BKTreasury treasury;
    BKAuthority authority;
    UniversalCommandGate gate;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    uint256[] roles = [
        0x77d72916e966418e6dc58a19999ae9934bef3f749f1547cde0a86e809f19c89b,
        0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70,
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a,
        0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6,
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929,
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3,
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07,
        0xdfbefbf47cfe66b701d8cfdbce1de81c821590819cb07e71cb01b6602fb0ee27
    ];

    constructor() {
        admin = cheats.addr(1);
        operator = cheats.addr(2);
        address _operator = operator;

        address[] memory operators = new address[](8);
        for (uint256 i; i < 8; ) {
            operators[i] = _operator;
            unchecked {
                ++i;
            }
        }

        uint256[] memory _roles = roles;
        bytes32[] memory roles_;
        assembly {
            roles_ := _roles
        }

        nft = new MockERC721();
        semiNFT = new MockERC1155();
        logInput = new LogInput();

        vm.startPrank(admin, admin);

        authority = new BKAuthority();
        authority.initialize(admin, roles_, operators);

        treasury = new BKTreasury();
        treasury.initialize(
            authority,
            AggregatorV3Interface(address(0)),
            "Test"
        );

        address[] memory vaults;

        gate = new UniversalCommandGate(authority, vaults);
        gate.whitelistTarget(logInput);

        authority.changeVault(address(treasury));

        vm.stopPrank();

        console.logAddress(gate.vault());
        assertEq(gate.vault(), address(treasury));
    }

    function setUp() public {
        nft.mint(operator, 1);
        semiNFT.mint(operator, 1, 5, "");
    }

    function testLogData() public {
        Asset memory asset = Asset(semiNFT, 1, operator, 0, "", abi.encode(4));

        vm.prank(operator);
        // semiNFT.safeTransferFrom(operator, gate, 1, 4, )
    }
}
