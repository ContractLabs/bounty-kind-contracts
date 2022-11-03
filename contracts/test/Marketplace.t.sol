// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {
    ERC20PermitUtil,
    ERC721PermitUtil,
    MarketplacePermitUtil
} from "./SigUtils.t.sol";

import {BK20} from "../BK20.sol";
import {BKNFT} from "../BK721.sol";
import {Treasury} from "../Treasury.sol";
import {Roles, Authority} from "../Authority.sol";
import {IMarketplace, Marketplace} from "../Marketplace.sol";

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract MarketplaceTest is Test {
    uint256 public adminPk;
    uint256 public buyerPk;
    uint256 public sellerPk;

    address public admin;
    address public buyer;
    address public seller;

    BK20 public pmt = new BK20();
    ERC20PermitUtil public erc20PermitUtil =
        new ERC20PermitUtil(pmt.DOMAIN_SEPARATOR());

    BKNFT public nft1 = new BKNFT();
    BKNFT public nft2 = new BKNFT();
    BKNFT public nft3 = new BKNFT();

    ERC721PermitUtil public erc721PermitUtil1;
    ERC721PermitUtil public erc721PermitUtil2;
    ERC721PermitUtil public erc721PermitUtil3;

    address[] public supportedContracts = [
        address(nft1),
        address(nft2),
        address(nft3)
    ];

    uint256 public id1;
    uint256 public id2;
    uint256 public id3;

    Treasury public treasury = new Treasury();
    Authority public authority = new Authority();
    Marketplace public marketplace = new Marketplace();

    MarketplacePermitUtil public marketplacePermitUtil;

    CheatCodes public cheats = CheatCodes(HEVM_ADDRESS);

    constructor() {
        (admin, adminPk) = makeAddrAndKey("admin");
        (buyer, buyerPk) = makeAddrAndKey("buyer");
        (seller, sellerPk) = makeAddrAndKey("seller");

        console.logAddress(admin);

        hoax(buyer, 10_000 ether);
        vm.stopPrank();
        hoax(seller, 10_000 ether);
        vm.stopPrank();
    }

    function setUp() public {
        vm.startPrank(admin, admin);

        authority.init();
        treasury.init(authority);

        pmt.init(authority, treasury, "PaymentToken", "PMT", 18);
        pmt.mint(buyer, 1_000_000);
        pmt.mint(seller, 1_000_000);

        erc20PermitUtil = new ERC20PermitUtil(pmt.DOMAIN_SEPARATOR());

        nft1.init("A", "", "", 0, pmt, authority, treasury, 0x00);
        nft2.init(
            "B",
            "",
            "",
            200,
            pmt,
            authority,
            treasury,
            bytes32(uint256(1))
        );
        nft3.init(
            "C",
            "",
            "",
            300,
            pmt,
            authority,
            treasury,
            bytes32(uint256(2))
        );

        id1 = nft1.mint(seller, 0);
        id2 = nft2.mint(seller, 1);
        id3 = nft3.mint(seller, 2);

        erc721PermitUtil1 = new ERC721PermitUtil(nft1.DOMAIN_SEPARATOR());
        erc721PermitUtil2 = new ERC721PermitUtil(nft2.DOMAIN_SEPARATOR());
        erc721PermitUtil3 = new ERC721PermitUtil(nft3.DOMAIN_SEPARATOR());

        marketplace.init(500, supportedContracts, authority, treasury);
        marketplacePermitUtil = new MarketplacePermitUtil(
            marketplace.DOMAIN_SEPARATOR()
        );

        vm.stopPrank();

        assertTrue(authority.hasRole(Roles.SIGNER_ROLE, admin));
    }

    function testValidRedeem() public {
        assertTrue(authority.hasRole(Roles.SIGNER_ROLE, admin));

        uint8 v;
        bytes32 r;
        bytes32 s;
        IMarketplace.Buyer memory _buyer;
        IMarketplace.Seller memory _seller;

        {
            ERC721PermitUtil.Permit memory permit = ERC721PermitUtil.Permit(
                address(marketplace),
                id1,
                nft1.nonces(id1),
                block.timestamp + 1 days
            );

            (v, r, s) = vm.sign(
                sellerPk,
                erc721PermitUtil1.getTypedDataHash(permit)
            );

            _seller = IMarketplace.Seller(
                v,
                r,
                s,
                id1,
                permit.deadline,
                100 ether,
                pmt,
                nft1
            );
        }

        uint256 orderDeadline = block.timestamp + 5 minutes;
        {
            ERC20PermitUtil.Permit memory permit = ERC20PermitUtil.Permit(
                buyer,
                address(marketplace),
                100 ether,
                pmt.nonces(buyer),
                orderDeadline
            );

            (v, r, s) = vm.sign(
                buyerPk,
                erc20PermitUtil.getTypedDataHash(permit)
            );

            _buyer = IMarketplace.Buyer(v, r, s, permit.deadline);
        }

        {
            MarketplacePermitUtil.Permit memory permit = MarketplacePermitUtil
                .Permit(
                    buyer,
                    address(_seller.nft),
                    address(_seller.payment),
                    _seller.unitPrice,
                    _seller.tokenId,
                    marketplace.nonces(buyer),
                    orderDeadline
                );
            (v, r, s) = vm.sign(
                adminPk,
                marketplacePermitUtil.getTypedDataHash(permit)
            );
        }

        vm.startPrank(buyer, buyer);

        marketplace.redeem(
            orderDeadline,
            _buyer,
            _seller,
            abi.encodePacked(r, s, v)
        );

        vm.stopPrank();
    }
}
