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

library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
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

contract Lockable is Ownable {
    bool private _lockedContract;
    mapping(address => bool) private _userBlocks;

    constructor() {
        _lockedContract = false;
    }

    modifier onlyUnLocked(
        address sender,
        address from,
        address to
    ) {
        require(!isLockedContract(), "Auth: Contract is locked");
        bool isLocked = isLockedUser(sender) ||
            isLockedUser(from) ||
            isLockedUser(to);
        require(!isLocked, "Auth: User is locked");
        _;
    }

    function userBlocks(address account) public view returns (bool) {
        return _userBlocks[account];
    }

    function isLockedUser(address account) public view returns (bool) {
        return _userBlocks[account];
    }

    function isLockedContract() public view returns (bool) {
        return _lockedContract;
    }

    function toggleLock() public onlyOwner {
        _lockedContract = !_lockedContract;
    }

    function setBlockUser(address account, bool status) public onlyOwner {
        _userBlocks[account] = status;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract ChargeFee {
    IERC20 private _feeToken;
    uint256 private _minFee;
    address private _taker;

    function minFee() public view returns (uint256) {
        return _minFee;
    }

    function feeToken() public view returns (IERC20) {
        return _feeToken;
    }

    function taker() public view returns (address) {
        return _taker;
    }

    function _changeMinFee(uint256 feeAmount) internal {
        _minFee = feeAmount;
    }

    function _changeFeeToken(IERC20 feeToken_) internal {
        _feeToken = feeToken_;
    }

    function _changeTaker(address _newTaker) internal {
        _taker = _newTaker;
    }

    function chargeFee(address account) internal returns (bool) {
        if (_minFee > 0) {
            return _feeToken.transferFrom(account, _taker, _minFee);
        }
        return true;
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

contract BusinessRole is Ownable, Ceo {
    address[] private _businesses;

    modifier onlyManager() {
        require(
            isOwner() || isCeo() || isBusiness(),
            "BusinessRole: caller is not business"
        );
        _;
    }

    function isBusiness() public view returns (bool) {
        for (uint256 i = 0; i < _businesses.length; i++) {
            if (_businesses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function getBusinessAddresses() public view returns (address[] memory) {
        return _businesses;
    }

    function setBusinessAddress(address[] memory businessAddresses)
        public
        onlyOwner
    {
        _businesses = businessAddresses;
    }
}

contract Withdrawable is BusinessRole {
    function _withdraw(uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Withdrawable: Insufficent balance to withdraw (coin)"
        );
        if (amount > 0) {
            payable(ceoAddress).transfer(amount);
        }
    }

    function _withdrawToken(IERC20 erc20, uint256 amount) internal {
        require(
            erc20.balanceOf(address(this)) >= amount,
            "Withdrawable: Insufficent balance to withdraw (token)"
        );

        if (amount > 0) {
            erc20.transfer(ceoAddress, amount);
        }
    }

    function withdraw(
        uint256 amount,
        address[] memory erc21s,
        uint256[] memory amountErc21s
    ) public onlyOwner {
        _withdraw(amount);
        for (uint256 i = 0; i < erc21s.length; i++) {
            _withdrawToken(IERC20(erc21s[i]), amountErc21s[i]);
        }
    }
}

interface IFiatContract {
    function getToken2USD(string memory _symbol)
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
    mapping(address => Token) private tokensFiat;
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

    function getTokensList() public view returns (address[] memory) {
        return fiats;
    }

    function getTokenFiat(address _fiat)
        public
        view
        returns (string memory _symbol, bool _existed)
    {
        return (tokensFiat[_fiat].symbol, tokensFiat[_fiat].existed);
    }

    function setTokensFiat(string[] memory _symbols, address[] memory addresses)
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

    function unsetTokenFiat(address[] memory _fiats) public onlyOwner {
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

    function resetTokenFiat() public onlyOwner {
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
        (, uint256 weitoken) = fiatContract.getToken2USD(
            tokensFiat[_fiatBuy].symbol
        );
        return _price.mul(weitoken).div(1 ether);
    }
}

interface IERC721Minterable {
    function mint(address to) external returns (uint256);

    function safeMint(address to) external;

    function multipleMint(address to, uint256 numItems) external;

    function multipleMintAccounts(
        address[] memory tos,
        uint256[] memory numItems
    ) external;
}

contract CompanyPackage is ChargeFee, Withdrawable, Lockable, FiatProvider {
    using Counters for Counters.Counter;

    event Register(
        address _user,
        address _erc721,
        uint256 _tokenId,
        uint256 _type
    );

    struct TypeNFT {
        uint256 price;
    }

    struct PackageNFT {
        mapping(uint256 => TypeNFT) typeNFTs;
        Counters.Counter _typeIdCounter;
    }

    mapping(address => PackageNFT) public packages;

    constructor(
        address ceo_,
        address token_,
        address taker_,
        uint256 minFee_,
        address fiatContract_
    ) {
        _transferCeo(ceo_);
        _changeFeeToken(IERC20(token_));
        _changeMinFee(minFee_);
        _changeTaker(taker_);
        fiatContract = IFiatContract(fiatContract_);
    }

    function setFeeToken(IERC20 feeToken) public onlyManager {
        _changeFeeToken(feeToken);
    }

    function setFee(address _newTaker, uint256 _newFeeAmount) public onlyManager {
        _changeTaker(_newTaker);
        _changeMinFee(_newFeeAmount);
    }

    function getTypeNFT(address _erc721, uint256 _typeNFT)
        public
        view
        returns (TypeNFT memory)
    {
        return packages[_erc721].typeNFTs[_typeNFT];
    }

    function setPackage(
        address _erc721,
        uint256 _typeNFT,
        uint256 price
    ) public onlyManager {
        if (_typeNFT >= packages[_erc721]._typeIdCounter.current()) {
            _typeNFT = packages[_erc721]._typeIdCounter.current();
            packages[_erc721]._typeIdCounter.increment();
        }

        packages[_erc721].typeNFTs[_typeNFT].price = price;
    }

    function buyNFT(
        address _erc721,
        uint256 _typeNFT,
        uint256 _numItems,
        address _fiat
    ) public payable isValidFiatBuy(_fiat) {
        require(
            packages[_erc721].typeNFTs[_typeNFT].price > 0,
            "Package: price is zero"
        );

        uint256 amountTotal = price2wei(
            packages[_erc721].typeNFTs[_typeNFT].price * _numItems,
            _fiat
        );

        if (_fiat == address(0)) {
            require(
                amountTotal <= msg.value,
                "Package: transfer amount exceeds balance"
            );
            payable(taker()).transfer(amountTotal);
            if (msg.value > amountTotal) {
                payable(msg.sender).transfer(msg.value - amountTotal);
            }
        } else {
            require(
                IERC20(_fiat).transferFrom(msg.sender, taker(), amountTotal),
                "NFTPackage: transfer is error"
            );
        }

        for (uint256 i = 0; i < _numItems; i++) {
            uint256 tokenId = IERC721Minterable(_erc721).mint(msg.sender);
            emit Register(msg.sender, _erc721, tokenId, _typeNFT);
        }
    }
}
