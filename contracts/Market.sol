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

contract FiatProvider is Ownable {
    using SafeMath for uint256;

    event SetFiat(string[] _symbols, address[] _address, address _from);
    event RemoveFiat(string[] _symbols, address[] _address, address _from);

    struct Token {
        string symbol;
        bool existed;
        uint256 index;
    }

    IFiatContract public fiatContract;
    mapping(address => Token) public tokensFiat;
    address[] public fiats;

    modifier isValidFiat(address[] memory _fiats) {
        require(_checkValidFiat(_fiats), "Fiat: fiat token is not approved");
        _;
    }
    modifier isValidFiatBuy(address _fiat) {
        require(tokensFiat[_fiat].existed, "Fiat: fiat token is not approved");
        _;
    }

    function setFiatContract(address _fiatContract) public onlyOwner {
        fiatContract = IFiatContract(_fiatContract);
    }

    function _checkValidFiat(address[] memory _fiats)
        internal
        view
        returns (bool)
    {
        if (fiats.length == 0) return false;
        bool isValid = true;
        for (uint256 i = 0; i < _fiats.length; i++) {
            if (!tokensFiat[_fiats[i]].existed) {
                isValid = false;
                break;
            }
        }
        return isValid;
    }

    function getFiats() public view returns (address[] memory) {
        return fiats;
    }

    function getTokensFiat(address _fiat)
        public
        view
        returns (string memory _symbol, bool _existed)
    {
        return (tokensFiat[_fiat].symbol, tokensFiat[_fiat].existed);
    }

    function setFiat(string[] memory _symbols, address[] memory addresses)
        public
        onlyOwner
    {
        require(
            _symbols.length == addresses.length,
            "Fiat: symbol and address length miss match"
        );
        for (uint256 i = 0; i < _symbols.length; i++) {
            tokensFiat[addresses[i]].symbol = _symbols[i];
            if (!tokensFiat[addresses[i]].existed) {
                fiats.push(addresses[i]);
                tokensFiat[addresses[i]].existed = true;
                tokensFiat[addresses[i]].index = fiats.length - 1;
            }
        }
        emit SetFiat(_symbols, addresses, msg.sender);
    }

    function unsetFiat(address[] memory _fiats) public onlyOwner {
        string[] memory _symbols;
        for (uint256 i = 0; i < _fiats.length; i++) {
            _symbols[i] = tokensFiat[_fiats[i]].symbol;
            if (tokensFiat[_fiats[i]].existed) {
                uint256 indexRemove = tokensFiat[_fiats[i]].index;
                fiats[indexRemove] = fiats[fiats.length - 1];
                tokensFiat[fiats[indexRemove]].index = indexRemove;
                fiats.pop();
                delete tokensFiat[_fiats[i]];
            }
        }
        emit RemoveFiat(_symbols, _fiats, msg.sender);
    }

    function resetFiat() public onlyOwner {
        string[] memory _symbols;
        for (uint256 i = 0; i < fiats.length; i++) {
            _symbols[i] = tokensFiat[fiats[i]].symbol;
            delete tokensFiat[fiats[i]];
        }
        emit RemoveFiat(_symbols, fiats, msg.sender);
        delete fiats;
    }

    function price2wei(uint256 _price, address _fiatBuy)
        public
        view
        returns (uint256)
    {
        (, uint256 weitoken) = fiatContract.getToken2Price(
            tokensFiat[_fiatBuy].symbol
        );
        return _price.mul(weitoken).div(1 ether);
    }
}

contract Ceo {
    address public ceoAddress;

    constructor() {
        _transferCeo(msg.sender);
    }

    modifier onlyCeo() {
        require(ceoAddress == msg.sender, "CEO: caller is not the ceo");
        _;
    }

    function isCeo() public view returns (bool) {
        return msg.sender == ceoAddress;
    }

    function transferCeo(address _address) public onlyCeo {
        require(_address != address(0), "CEO: newAddress is the zero address");
        _transferCeo(_address);
    }

    function renounceCeo() public onlyCeo {
        _transferCeo(address(0));
    }

    function _transferCeo(address _address) internal {
        ceoAddress = _address;
    }
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IERC21 {
    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

contract Market is FiatProvider, Ceo {
    using SafeMath for uint256;

    event _setPrice(
        address _game,
        uint256[] _tokenIds,
        uint256 _price,
        uint8 _type
    );
    event _resetPrice(address _game, uint256 _orderId);
    struct Game {
        uint256 fee;
        uint256 limitFee;
        uint256 creatorFee;
        mapping(uint256 => Price) tokenPrice;
        GameFee[] arrFees;
        mapping(string => GameFee) fees;
    }
    struct Price {
        uint256[] tokenIds; // package tokenId
        address maker; // address post
        uint256 price; // price of the package (unit is USD/JPY/VND/...) * 1 ether
        address[] fiat; // payable fiat
        address buyByFiat;
        bool isBuy; // order status
    }
    struct GameFee {
        string fee; // bao nhieu phan `Percen` cua weiPrice
        address taker; //
        uint256 percent;
        bool existed;
    }

    address public MarketSub;
    mapping(address => Game) public Games;
    address[] public arrGames;
    uint256 public Percen = 1000;

    constructor(
        address marketSub_,
        address fiatContract_,
        string[] memory symbols_,
        address[] memory addrrs_,
        address ceoAddress_
    ) {
        setMarketSub(marketSub_);
        _transferCeo(ceoAddress_);
        setFiatContract(fiatContract_);
        setFiat(symbols_, addrrs_);
    }

    modifier onlySub() {
        require(msg.sender == MarketSub, "Market: caller is not the sub");
        _;
    }

    function setMarketSub(address _sub) public onlyOwner {
        MarketSub = _sub;
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function checkIsOwnerOf(address _game, uint256[] memory _tokenIds)
        public
        view
        returns (bool)
    {
        bool isValid = true;
        IERC721 erc721 = IERC721(_game);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (erc721.ownerOf(_tokenIds[i]) != msg.sender) {
                isValid = false;
                break;
            }
        }
        return isValid;
    }

    modifier isOwnerOf(address _game, uint256[] memory _tokenIds) {
        require(
            checkIsOwnerOf(_game, _tokenIds),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function ownerOf(address _game, uint256 _tokenId)
        public
        view
        returns (address)
    {
        IERC721 erc721 = IERC721(_game);
        return erc721.ownerOf(_tokenId);
    }

    function tokenId2wei(
        address _game,
        uint256 _orderId,
        address _fiatBuy
    ) public view returns (uint256) {
        uint256 _price = Games[_game].tokenPrice[_orderId].price;
        return price2wei(_price, _fiatBuy);
    }

    function getTokenPrice(address _game, uint256 _orderId)
        public
        view
        returns (
            address _maker,
            uint256[] memory _tokenIds,
            uint256 _price,
            address[] memory _fiat,
            address _buyByFiat,
            bool _isBuy
        )
    {
        return (
            Games[_game].tokenPrice[_orderId].maker,
            Games[_game].tokenPrice[_orderId].tokenIds,
            Games[_game].tokenPrice[_orderId].price,
            Games[_game].tokenPrice[_orderId].fiat,
            Games[_game].tokenPrice[_orderId].buyByFiat,
            Games[_game].tokenPrice[_orderId].isBuy
        );
    }

    function getArrGames() public view returns (address[] memory) {
        return arrGames;
    }

    function updateArrGames(address _game) internal {
        bool flag = false;
        for (uint256 i = 0; i < arrGames.length; i++) {
            if (arrGames[i] == _game) {
                flag = true;
                break;
            }
        }
        if (!flag) arrGames.push(_game);
    }

    function setPrice(
        uint256 _orderId,
        address _game,
        uint256[] memory _tokenIds,
        uint256 _price,
        address[] memory _fiat
    ) internal {
        require(
            Games[_game].tokenPrice[_orderId].maker == address(0) ||
                Games[_game].tokenPrice[_orderId].maker == msg.sender,
            "Market: Orderid has been taken"
        );
        Games[_game].tokenPrice[_orderId] = Price(
            _tokenIds,
            msg.sender,
            _price,
            _fiat,
            address(0),
            false
        );
        updateArrGames(_game);
    }

    function calFee(
        address _game,
        string memory _fee,
        uint256 _price
    ) public view returns (uint256) {
        uint256 amount = _price.mul(Games[_game].fees[_fee].percent).div(
            Percen
        );
        return amount;
    }

    function calPrice(address _game, uint256 _orderId)
        public
        view
        returns (
            address _tokenOwner,
            uint256 _price,
            address[] memory _fiat,
            address _buyByFiat,
            bool _isBuy
        )
    {
        return (
            Games[_game].tokenPrice[_orderId].maker,
            Games[_game].tokenPrice[_orderId].price,
            Games[_game].tokenPrice[_orderId].fiat,
            Games[_game].tokenPrice[_orderId].buyByFiat,
            Games[_game].tokenPrice[_orderId].isBuy
        );
    }

    function setPriceFee(
        uint256 _orderId,
        address _game,
        uint256[] memory _tokenIds,
        uint256 _price,
        address[] memory _fiat
    ) public isOwnerOf(_game, _tokenIds) isValidFiat(_fiat) {
        setPrice(_orderId, _game, _tokenIds, _price, _fiat);
        emit _setPrice(_game, _tokenIds, _price, 1);
    }

    function getGame(address _game)
        public
        view
        returns (
            uint256 _fee,
            uint256 _limitFee,
            uint256 _creatorFee
        )
    {
        return (
            Games[_game].fee,
            Games[_game].limitFee,
            Games[_game].creatorFee
        );
    }

    function getGameFees(address _game)
        public
        view
        returns (
            string[] memory _fees,
            address[] memory _takers,
            uint256[] memory _percents,
            uint256 _sumGamePercent
        )
    {
        uint256 length = Games[_game].arrFees.length;
        string[] memory fees = new string[](length);
        address[] memory takers = new address[](length);
        uint256[] memory percents = new uint256[](length);
        uint256 sumGamePercent = 0;
        for (uint256 i = 0; i < length; i++) {
            GameFee storage gameFee = Games[_game].arrFees[i];
            fees[i] = gameFee.fee;
            takers[i] = gameFee.taker;
            percents[i] = gameFee.percent;
            sumGamePercent += gameFee.percent;
        }

        return (fees, takers, percents, sumGamePercent);
    }

    function getGameFeePercent(address _game, string memory _fee)
        public
        view
        returns (uint256)
    {
        return Games[_game].fees[_fee].percent;
    }

    function setLimitFee(
        address _game,
        uint256 _fee,
        uint256 _limitFee,
        uint256 _creatorFee,
        string[] memory _gameFees,
        address[] memory _takers,
        uint256[] memory _percents
    ) public onlyOwner {
        require(
            _fee >= 0 && _limitFee >= 0,
            "Market: fee and limit fee must be greater than or equal to 0"
        );
        Games[_game].fee = _fee;
        Games[_game].limitFee = _limitFee;
        Games[_game].creatorFee = _creatorFee;

        for (uint256 i = 0; i < _gameFees.length; i++) {
            if (!Games[_game].fees[_gameFees[i]].existed) {
                GameFee memory newFee = GameFee({
                    fee: _gameFees[i],
                    taker: _takers[i],
                    percent: _percents[i],
                    existed: true
                });
                Games[_game].fees[_gameFees[i]] = newFee;
                Games[_game].arrFees.push(newFee);
            } else {
                Games[_game].fees[_gameFees[i]].percent = _percents[i];
                Games[_game].fees[_gameFees[i]].taker = _takers[i];
                Games[_game].arrFees[i].percent = _percents[i];
                Games[_game].arrFees[i].taker = _takers[i];
            }
        }
        updateArrGames(_game);
    }

    function setLimitFeeAll(
        address[] memory _games,
        uint256[] memory _fees,
        uint256[] memory _limitFees,
        uint256[] memory _creatorFees,
        string[][] memory _gameFees,
        address[][] memory _takers,
        uint256[][] memory _percents
    ) public onlyOwner {
        require(
            _games.length == _fees.length,
            "Market: Games and fees length miss match"
        );
        for (uint256 i = 0; i < _games.length; i++) {
            setLimitFee(
                _games[i],
                _fees[i],
                _limitFees[i],
                _creatorFees[i],
                _gameFees[i],
                _takers[i],
                _percents[i]
            );
        }
    }

    function _withdraw(uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Market: Insufficent balance to withdraw (coin)"
        );
        if (amount > 0) {
            payable(ceoAddress).transfer(amount);
        }
    }

    function withdraw(
        uint256 amount,
        address[] memory _tokenERC21s,
        uint256[] memory _amountERC21s
    ) public onlyOwner {
        _withdraw(amount);
        for (uint256 i = 0; i < _tokenERC21s.length; i++) {
            if (_tokenERC21s[i] != address(0)) {
                IERC21 erc21 = IERC21(_tokenERC21s[i]);
                require(
                    erc21.balanceOf(address(this)) >= _amountERC21s[i],
                    "Market: Insufficent balance to withdraw (token)"
                );
                if (_amountERC21s[i] > 0) {
                    erc21.transfer(ceoAddress, _amountERC21s[i]);
                }
            }
        }
    }

    function removePrice(address _game, uint256 _orderId) public {
        require(
            msg.sender == Games[_game].tokenPrice[_orderId].maker,
            "Market: Orderid has been taken"
        );
        resetPrice(_game, _orderId);
    }

    function resetPrice(address _game, uint256 _orderId) internal {
        delete Games[_game].tokenPrice[_orderId];
        emit _resetPrice(_game, _orderId);
    }

    function resetPrice4sub(address _game, uint256 _tokenId) public onlySub {
        resetPrice(_game, _tokenId);
    }

    function sellNfts(
        uint256[] memory _orderIds,
        address[] memory _game,
        uint256[][] memory _tokenIds,
        uint256[] memory _price,
        address[][] memory _fiats
    ) public {
        require(
            _orderIds.length == _tokenIds.length,
            "Market: Orders and tokenIds length miss match"
        );
        for (uint256 i = 0; i < _orderIds.length; i++) {
            require(
                checkIsOwnerOf(_game[i], _tokenIds[i]),
                "Ownable: caller is not the owner"
            );
            require(
                _checkValidFiat(_fiats[i]),
                "Fiat: fiat token is not approved"
            );
            setPriceFee(
                _orderIds[i],
                _game[i],
                _tokenIds[i],
                _price[i],
                _fiats[i]
            );
        }
    }
}
