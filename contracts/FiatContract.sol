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

contract FiatContract is Ownable {
    using SafeMath for uint256;

    event SetPrice(string[] _symbols, uint256[] _token2Price, address _from);
    struct Token {
        string symbol;
        uint256 token2Price;
        bool existed;
    }

    uint256 public mulNum = 2;
    uint256 public lastCode = 3;
    uint256 public callTime = 1;
    uint256 public baseTime = 3;
    uint256 public plusNum = 1;

    mapping(string => Token) private tokens;
    string[] private tokenArr;

    function setInput(
        uint256 _mulNum,
        uint256 _lastCode,
        uint256 _callTime,
        uint256 _baseTime,
        uint256 _plusNum
    ) public onlyOwner {
        mulNum = _mulNum;
        lastCode = _lastCode;
        callTime = _callTime;
        baseTime = _baseTime;
        plusNum = _plusNum;
    }

    function setPrice(
        string[] memory _symbols,
        uint256[] memory _token2Price,
        uint256 _code
    ) public onlyOwner {
        require(_code == findNumber(lastCode), "FIAT: Code is not match");
        for (uint256 i = 0; i < _symbols.length; i++) {
            tokens[_symbols[i]].token2Price = _token2Price[i];
            if (!tokens[_symbols[i]].existed) {
                tokenArr.push(_symbols[i]);
                tokens[_symbols[i]].existed = true;
                tokens[_symbols[i]].symbol = _symbols[i];
            }
        }
        emit SetPrice(_symbols, _token2Price, msg.sender);
    }

    function getToken2Price(string memory _symbol)
        public
        view
        returns (string memory _symbolToken, uint256 _token2Price)
    {
        return (tokens[_symbol].symbol, tokens[_symbol].token2Price);
    }

    function getTokenArr() public view returns (string[] memory) {
        return tokenArr;
    }

    function findNumber(uint256 a) internal returns (uint256) {
        uint256 b = a.mul(mulNum) - plusNum;
        if (callTime % 3 == 0) {
            for (uint256 i = 0; i < baseTime; i++) {
                b += (a + plusNum).div(mulNum);
            }
            b = b.div(baseTime) + plusNum;
        }
        if (b > 9293410619286421) {
            mulNum = callTime % 9 == 1 ? 2 : callTime % 9;
            b = 3;
        }
        ++callTime;
        lastCode = b;
        return b;
    }

    function esfindNumber1(uint256 a)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 aa = a.mul(mulNum);
        uint256 aaa = a * 5;
        uint256 b = a.mul(mulNum) - plusNum;
        uint256 c = b;
        for (uint256 i = 0; i < baseTime; i++) {
            c += (a + plusNum).div(mulNum);
        }
        uint256 d = c.div(baseTime) + plusNum;
        return (b, c, d, aa, aaa);
    }

    function esfindNumber(uint256 a) public view returns (uint256) {
        uint256 b = a.mul(mulNum) - plusNum;
        if (callTime % 3 == 0) {
            for (uint256 i = 0; i < baseTime; i++) {
                b += (a + plusNum).div(mulNum);
            }
            b = b.div(baseTime) + plusNum;
        }
        if (b > 9293410619286421) {
            b = 3;
        }
        return b;
    }
}
