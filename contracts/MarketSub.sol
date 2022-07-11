// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    address private _owner;

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: newOwner is zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IFiatContract {
    function getToken2Price(string memory _symbol)
        external
        view
        returns (string memory _symbolToken, uint256 _token2Price);
}

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function metadata(uint256 tokenId) external view returns (address creator);
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IMarket {
    function ceoAddress() external view returns (address);

    function fiatContract() external view returns (address);

    function getTokensFiat(address token)
        external
        view
        returns (string memory symbol, bool existed);

    function price2wei(uint256 _price, address _fiatBuy)
        external
        view
        returns (uint256);

    function tokenId2wei(
        address _game,
        uint256 _tokenId,
        address _fiatBuy
    ) external view returns (uint256);

    function Percen() external view returns (uint256);

    function getGame(address _game)
        external
        view
        returns (
            uint256 _fee,
            uint256 _limitFee,
            uint256 _creatorFee
        );

    function getGameFees(address _game)
        external
        view
        returns (
            string[] memory _fees,
            address[] memory _takers,
            uint256[] memory _percent,
            uint256 sumGamePercent
        );

    function getGameFeePercent(address _game, string memory _fee)
        external
        view
        returns (uint256);

    function getTokenPrice(address _game, uint256 _orderId)
        external
        view
        returns (
            address _maker,
            uint256[] memory _tokenIds,
            uint256 _price,
            address[] memory _fiat,
            address _buyByFiat,
            bool _isBuy
        );

    function resetPrice4sub(address _game, uint256 _tokenId) external;
}

contract MarketSub is Ownable {
    using SafeMath for uint256;

    IMarket public Market;

    constructor(address market_) {
        setMarket(market_);
    }

    modifier isValidFiatBuy(address _fiat) {
        (, bool existed) = Market.getTokensFiat(_fiat);
        require(existed, "Fiat: fiat token is not approved");
        _;
    }

    function setMarket(address _market) public onlyOwner {
        Market = IMarket(_market);
    }

    function calBusinessFee(
        address _game,
        string memory _symbolFiatBuy,
        uint256 weiPrice
    ) public view returns (uint256 _businessProfit, uint256 _creatorProfit) {
        (uint256 fee, uint256 limitFee, uint256 creatorFee) = Market.getGame(
            _game
        );
        uint256 businessProfit = (weiPrice.mul(fee)).div(Market.Percen());
        IFiatContract fiatCt = IFiatContract(Market.fiatContract());
        (, uint256 tokenOnPrice) = fiatCt.getToken2Price(_symbolFiatBuy);
        uint256 limitFee2Token = (tokenOnPrice.mul(limitFee)).div(1 ether);
        if (weiPrice > 0 && businessProfit < limitFee2Token)
            businessProfit = limitFee2Token;
        uint256 creatorProfit = (weiPrice.mul(creatorFee)).div(Market.Percen());
        return (businessProfit, creatorProfit);
    }

    function buy(
        address _game,
        uint256 _orderId,
        address _fiatBuy,
        string memory _symbolFiatBuy
    ) public payable isValidFiatBuy(_fiatBuy) {
        (address _maker, uint256[] memory _tokenIds, , , , ) = Market
            .getTokenPrice(_game, _orderId);
        IERC721 erc721 = IERC721(_game);
        require(
            erc721.isApprovedForAll(_maker, address(this)),
            "MarketSub: sub is not approved for all"
        );
        // pay the fees
        tobuy(_game, _orderId, _fiatBuy, _symbolFiatBuy, _maker, _tokenIds[0]);
        // transfer tokenId
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            erc721.transferFrom(_maker, msg.sender, _tokenIds[i]);
        }
        // reset price in market
        Market.resetPrice4sub(_game, _orderId);
    }

    function tobuy(
        address _game,
        uint256 _orderId,
        address _fiatBuy,
        string memory _symbolFiatBuy,
        address _maker,
        uint256 tokenId
    ) internal {
        uint256 weiPrice = Market.tokenId2wei(_game, _orderId, _fiatBuy);
        (uint256 businessProfit, uint256 creatorProfit) = calBusinessFee(
            _game,
            _symbolFiatBuy,
            weiPrice
        );
        (, , , uint256 sumGamePercent) = Market.getGameFees(_game);
        uint256 sumGameProfit = (weiPrice.mul(sumGamePercent)).div(
            Market.Percen()
        );
        uint256 ownerProfit = (weiPrice.sub(businessProfit))
            .sub(creatorProfit)
            .sub(sumGameProfit);

        tobuySub(
            _game,
            _fiatBuy,
            weiPrice,
            _maker,
            ownerProfit,
            businessProfit,
            creatorProfit,
            sumGameProfit,
            tokenId
        );
        tobuySub2(_game, _fiatBuy, weiPrice);
    }

    function tobuySub(
        address _game,
        address _fiatBuy,
        uint256 weiPrice,
        address _maker,
        uint256 ownerProfit,
        uint256 businessProfit,
        uint256 creatorProfit,
        uint256 sumGameProfit,
        uint256 tokenId
    ) internal {
        IERC721 erc721 = IERC721(_game);
        address ceo = Market.ceoAddress();

        if (_fiatBuy == address(0)) {
            require(
                weiPrice <= msg.value,
                "MarketSub: transfer amount exceeds balance"
            );
            if (ownerProfit > 0) payable(_maker).transfer(ownerProfit);
            if (businessProfit > 0) payable(ceo).transfer(businessProfit);
            if (creatorProfit > 0) {
                address creator = erc721.metadata(tokenId);
                payable(creator).transfer(creatorProfit);
            }
        } else {
            IERC20 erc20 = IERC20(_fiatBuy);
            uint256 totalRequire = weiPrice;
            require(
                erc20.transferFrom(msg.sender, address(this), totalRequire),
                "MarketSub: transfer amount exceeds balance"
            );
            if (ownerProfit > 0) erc20.transfer(_maker, ownerProfit);
            if (businessProfit > 0) erc20.transfer(ceo, businessProfit);
            if (creatorProfit > 0) {
                address creatorr = erc721.metadata(tokenId);
                erc20.transfer(creatorr, creatorProfit);
            }
        }
    }

    function tobuySub2(
        address _game,
        address _fiatBuy,
        uint256 weiPrice
    ) internal {
        (, address[] memory takers, uint256[] memory percents, ) = Market
            .getGameFees(_game);
        for (uint256 i = 0; i < takers.length; i++) {
            uint256 gameProfit = (weiPrice.mul(percents[i])).div(
                Market.Percen()
            );
            if (_fiatBuy == address(0)) {
                payable(takers[i]).transfer(gameProfit);
            } else {
                IERC20 erc20 = IERC20(_fiatBuy);
                erc20.transfer(takers[i], gameProfit);
            }
        }
    }
}
