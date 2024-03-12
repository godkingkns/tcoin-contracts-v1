// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2023 All rights reserved
pragma solidity ^0.8.23;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Counters {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract Ownable {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipTransferredPlus(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "OWNERSHIP_ERROR_1");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address token0);
}

interface IUniswapV2Router02Eth {
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02Pls {
    function WPLS() external pure returns (address);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function factory() external pure returns (address);

    function WPLS() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface ITardToken {
    function initialBuyTimestamp(
        address user
    ) external view returns (uint256 timestamp);

    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

library SignedSafeMath {
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

library SafeCast {
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(
            value <= type(uint224).max,
            "SafeCast: value doesn't fit in 224 bits"
        );
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(
            value <= type(uint128).max,
            "SafeCast: value doesn't fit in 128 bits"
        );
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {
        require(
            value <= type(uint96).max,
            "SafeCast: value doesn't fit in 96 bits"
        );
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(
            value <= type(uint64).max,
            "SafeCast: value doesn't fit in 64 bits"
        );
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(
            value <= type(uint32).max,
            "SafeCast: value doesn't fit in 32 bits"
        );
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(
            value <= type(uint16).max,
            "SafeCast: value doesn't fit in 16 bits"
        );
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(
            value <= type(uint8).max,
            "SafeCast: value doesn't fit in 8 bits"
        );
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(
            value >= type(int128).min && value <= type(int128).max,
            "SafeCast: value doesn't fit in 128 bits"
        );
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(
            value >= type(int64).min && value <= type(int64).max,
            "SafeCast: value doesn't fit in 64 bits"
        );
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(
            value >= type(int32).min && value <= type(int32).max,
            "SafeCast: value doesn't fit in 32 bits"
        );
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(
            value >= type(int16).min && value <= type(int16).max,
            "SafeCast: value doesn't fit in 16 bits"
        );
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(
            value >= type(int8).min && value <= type(int8).max,
            "SafeCast: value doesn't fit in 8 bits"
        );
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(
            value <= uint256(type(int256).max),
            "SafeCast: value doesn't fit in an int256"
        );
        return int256(value);
    }
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns (uint256);

    function distributeDividends() external payable;

    function withdrawDividend() external;

    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount,
        address received
    );
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(
        address _owner
    ) external view returns (uint256);

    function withdrawnDividendOf(
        address _owner
    ) external view returns (uint256);

    function accumulativeDividendOf(
        address _owner
    ) external view returns (uint256);
}

abstract contract DividendPayingToken is
    ERC20,
    DividendPayingTokenInterface,
    DividendPayingTokenOptionalInterface
{
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
    uint256 internal constant magnitude = 2 ** 128;
    uint256 internal magnifiedDividendPerShare;
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;
    uint256 public totalDividendsDistributed;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    receive() external payable {
        distributeDividends();
    }

    function distributeDividends() public payable override {
        require(totalSupply() > 0);
        if (msg.value > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (msg.value).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, msg.value);
            totalDividendsDistributed = totalDividendsDistributed.add(
                msg.value
            );
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender), payable(msg.sender));
    }

    function _withdrawDividendOfUser(
        address payable user,
        address payable to
    ) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            emit DividendWithdrawn(user, _withdrawableDividend, to);
            (bool success, ) = to.call{value: _withdrawableDividend}("");
            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            }
            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(
        address _owner
    ) public view override returns (uint256) {
        if (magnifiedDividendPerShare > 0) {
            return
                accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
        }
        return 0;
    }

    function withdrawnDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return
            magnifiedDividendPerShare
                .mul(balanceOf(_owner))
                .toInt256()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256() / magnitude;
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].sub((magnifiedDividendPerShare.mul(value)).toInt256());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].add((magnifiedDividendPerShare.mul(value)).toInt256());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);
        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }

    function getAccount(
        address _account
    )
        public
        view
        returns (uint256 _withdrawableDividends, uint256 _withdrawnDividends)
    {
        _withdrawableDividends = withdrawableDividendOf(_account);
        _withdrawnDividends = withdrawnDividends[_account];
    }
}

contract TardIncentivesTracker is Ownable {
    event FloorPrice(
        uint256 _amount,
        uint256 baseBuyTax,
        uint256 baseFees,
        uint256 currentPriceE18
    );
    event InnerSwapSell(
        uint256 curOrderId,
        uint256 key,
        uint256 allowAmount,
        uint256 currentFees,
        uint256 currentRewardTokens
    );
    event InnerSwapTransfer(
        uint256 curOrderId,
        uint256 key,
        uint256 toTransfer
    );
    event OuterSwapTransfer(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 senderBalance,
        uint256 allowAmount,
        uint256 remainingAmount
    );
    event OuterSwapSell(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 allowAmount,
        uint256 fees,
        uint256 rewardTokens,
        uint256 totEthOut,
        uint256 midPriceE18,
        uint256 sellCapFloorPricePerTokenE18
    );
    event OuterSwapBuy(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 spentEth,
        uint256 remainingAmount,
        uint256 baseFees,
        uint256 floorFees,
        uint256 currentpriceE18,
        uint256 midPriceE18,
        uint256 higherPriceUsdtPerEthE18
    );
    event FloorFee(
        uint256 _amount,
        uint256 effectivePriceE18,
        uint256 buyFeeFloorPricePerTokenE18,
        uint256 floorBuyTax
    );
    uint256 public allowSome = 10_000;
    struct Node {
        uint parent;
        uint left;
        uint right;
        bool red;
        uint256 timestamp;
        uint256 amount;
        uint256 usdPerEth;
    }
    struct NodeInfo {
        uint256 key;
        uint256 timestamp;
        uint256 amount;
        uint256 allowedFromNode;
        uint256 currentFees;
        uint256 currentRewardTokens;
        uint256 usdPerEth;
    }
    struct Tree {
        uint root;
        mapping(uint => Node) nodes;
        uint256 nodesCount;
    }
    uint private constant EMPTY = 0;

    function first(Tree storage self) internal view returns (uint _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].left != EMPTY) {
                _key = self.nodes[_key].left;
            }
        }
    }

    function last(Tree storage self) internal view returns (uint _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].right != EMPTY) {
                _key = self.nodes[_key].right;
            }
        }
    }

    function next(
        Tree storage self,
        uint target
    ) internal view returns (uint cursor) {
        require(target != EMPTY);
        if (self.nodes[target].right != EMPTY) {
            cursor = treeMinimum(self, self.nodes[target].right);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].right) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function prev(
        Tree storage self,
        uint target
    ) internal view returns (uint cursor) {
        require(target != EMPTY);
        if (self.nodes[target].left != EMPTY) {
            cursor = treeMaximum(self, self.nodes[target].left);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].left) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function exists(Tree storage self, uint key) internal view returns (bool) {
        return
            (key != EMPTY) &&
            ((key == self.root) || (self.nodes[key].parent != EMPTY));
    }

    function isEmpty(uint key) internal pure returns (bool) {
        return key == EMPTY;
    }

    function getEmpty() internal pure returns (uint) {
        return EMPTY;
    }

    function getNodeStorage(
        Tree storage self,
        uint key
    ) internal view returns (Node storage) {
        require(exists(self, key));
        return self.nodes[key];
    }

    function getNode(
        Tree storage self,
        uint key
    ) internal view returns (Node memory) {
        require(exists(self, key));
        return self.nodes[key];
    }

    function insert(
        Tree storage self,
        uint key,
        uint256 timestamp,
        uint256 amount,
        uint256 higherPriceUsdtPerEthE18
    ) internal {
        require(key != EMPTY);
        require(!exists(self, key));
        uint cursor = EMPTY;
        uint probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (key < probe) {
                probe = self.nodes[probe].left;
            } else {
                probe = self.nodes[probe].right;
            }
        }
        self.nodes[key] = Node({
            parent: cursor,
            left: EMPTY,
            right: EMPTY,
            red: true,
            timestamp: timestamp,
            amount: amount,
            usdPerEth: higherPriceUsdtPerEthE18
        });
        if (cursor == EMPTY) {
            self.root = key;
        } else if (key < cursor) {
            self.nodes[cursor].left = key;
        } else {
            self.nodes[cursor].right = key;
        }
        insertFixup(self, key);
        self.nodesCount += 1;
    }

    function remove(Tree storage self, uint key) internal {
        require(key != EMPTY);
        require(exists(self, key));
        uint probe;
        uint cursor;
        if (self.nodes[key].left == EMPTY || self.nodes[key].right == EMPTY) {
            cursor = key;
        } else {
            cursor = self.nodes[key].right;
            while (self.nodes[cursor].left != EMPTY) {
                cursor = self.nodes[cursor].left;
            }
        }
        if (self.nodes[cursor].left != EMPTY) {
            probe = self.nodes[cursor].left;
        } else {
            probe = self.nodes[cursor].right;
        }
        uint yParent = self.nodes[cursor].parent;
        self.nodes[probe].parent = yParent;
        if (yParent != EMPTY) {
            if (cursor == self.nodes[yParent].left) {
                self.nodes[yParent].left = probe;
            } else {
                self.nodes[yParent].right = probe;
            }
        } else {
            self.root = probe;
        }
        bool doFixup = !self.nodes[cursor].red;
        if (cursor != key) {
            replaceParent(self, cursor, key);
            self.nodes[cursor].left = self.nodes[key].left;
            self.nodes[self.nodes[cursor].left].parent = cursor;
            self.nodes[cursor].right = self.nodes[key].right;
            self.nodes[self.nodes[cursor].right].parent = cursor;
            self.nodes[cursor].red = self.nodes[key].red;
            (cursor, key) = (key, cursor);
        }
        if (doFixup) {
            removeFixup(self, probe);
        }
        delete self.nodes[cursor];
        self.nodesCount -= 1;
    }

    function treeMinimum(
        Tree storage self,
        uint key
    ) private view returns (uint) {
        while (self.nodes[key].left != EMPTY) {
            key = self.nodes[key].left;
        }
        return key;
    }

    function treeMaximum(
        Tree storage self,
        uint key
    ) private view returns (uint) {
        while (self.nodes[key].right != EMPTY) {
            key = self.nodes[key].right;
        }
        return key;
    }

    function rotateLeft(Tree storage self, uint key) private {
        uint cursor = self.nodes[key].right;
        uint keyParent = self.nodes[key].parent;
        uint cursorLeft = self.nodes[cursor].left;
        self.nodes[key].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].left) {
            self.nodes[keyParent].left = cursor;
        } else {
            self.nodes[keyParent].right = cursor;
        }
        self.nodes[cursor].left = key;
        self.nodes[key].parent = cursor;
    }

    function rotateRight(Tree storage self, uint key) private {
        uint cursor = self.nodes[key].left;
        uint keyParent = self.nodes[key].parent;
        uint cursorRight = self.nodes[cursor].right;
        self.nodes[key].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].right) {
            self.nodes[keyParent].right = cursor;
        } else {
            self.nodes[keyParent].left = cursor;
        }
        self.nodes[cursor].right = key;
        self.nodes[key].parent = cursor;
    }

    function insertFixup(Tree storage self, uint key) private {
        uint cursor;
        while (key != self.root && self.nodes[self.nodes[key].parent].red) {
            uint keyParent = self.nodes[key].parent;
            if (keyParent == self.nodes[self.nodes[keyParent].parent].left) {
                cursor = self.nodes[self.nodes[keyParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].right) {
                        key = keyParent;
                        rotateLeft(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateRight(self, self.nodes[keyParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].left) {
                        key = keyParent;
                        rotateRight(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateLeft(self, self.nodes[keyParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }

    function replaceParent(Tree storage self, uint a, uint b) private {
        uint bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }

    function removeFixup(Tree storage self, uint key) private {
        uint cursor;
        while (key != self.root && !self.nodes[key].red) {
            uint keyParent = self.nodes[key].parent;
            if (key == self.nodes[keyParent].left) {
                cursor = self.nodes[keyParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateLeft(self, keyParent);
                    cursor = self.nodes[keyParent].right;
                }
                if (
                    !self.nodes[self.nodes[cursor].left].red &&
                    !self.nodes[self.nodes[cursor].right].red
                ) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[keyParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, keyParent);
                    key = self.root;
                }
            } else {
                cursor = self.nodes[keyParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateRight(self, keyParent);
                    cursor = self.nodes[keyParent].left;
                }
                if (
                    !self.nodes[self.nodes[cursor].right].red &&
                    !self.nodes[self.nodes[cursor].left].red
                ) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[keyParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, keyParent);
                    key = self.root;
                }
            }
        }
        self.nodes[key].red = false;
    }

    function externalFirst(
        address user
    ) external view onlyOwnerPlus returns (uint _key) {
        return first(userBuys[user]);
    }

    function externalLast(
        address user
    ) external view onlyOwnerPlus returns (uint _key) {
        return last(userBuys[user]);
    }

    function externalNext(
        address user,
        uint target
    ) external view onlyOwnerPlus returns (uint cursor) {
        return next(userBuys[user], target);
    }

    function externalPrev(
        address user,
        uint target
    ) external view onlyOwnerPlus returns (uint cursor) {
        return prev(userBuys[user], target);
    }

    function externalExists(
        address user,
        uint key
    ) external view onlyOwnerPlus returns (bool) {
        return exists(userBuys[user], key);
    }

    function externalIsEmpty(uint key) external pure returns (bool) {
        return isEmpty(key);
    }

    function externalGetEmpty() external pure returns (uint) {
        return getEmpty();
    }

    function externalGetNode(
        address user,
        uint key
    ) external view onlyOwnerPlus returns (Node memory) {
        return getNode(userBuys[user], key);
    }

    function externalInsert(
        address user,
        uint key,
        uint256 timestamp,
        uint256 amount,
        uint256 higherPriceUsdtPerEthE18
    ) external onlyOwnerPlus {
        insert(
            userBuys[user],
            key,
            timestamp,
            amount,
            higherPriceUsdtPerEthE18
        );
    }

    function externalRemove(address user, uint key) external onlyOwnerPlus {
        remove(userBuys[user], key);
    }

    function externalUpdateNode(
        address user,
        uint key,
        uint newParent,
        uint newLeft,
        uint newRight,
        bool newRed,
        uint256 newTimestamp,
        uint256 newAmount,
        uint256 newUsdPerEth
    ) external onlyOwnerPlus {
        require(exists(userBuys[user], key), "NODE_DOES_NOT_EXIST");
        Tree storage tree = userBuys[user];
        tree.nodes[key] = Node(
            newParent,
            newLeft,
            newRight,
            newRed,
            newTimestamp,
            newAmount,
            newUsdPerEth
        );
    }

    function externalGetNodesRange(
        address user,
        uint256 _limit,
        uint256 _pageNumber
    ) external view returns (Node[] memory) {
        require(_limit > 0, "Limit must be positive");
        uint256 start = _pageNumber * _limit;
        Node[] memory nodes = new Node[](_limit);
        Tree storage tree = userBuys[user];
        uint currentIndex = 0;
        uint arrayIndex = 0;
        uint key = first(tree);
        while (key != getEmpty() && arrayIndex < _limit) {
            if (currentIndex >= start) {
                nodes[arrayIndex++] = getNode(tree, key);
            }
            key = next(tree, key);
            currentIndex++;
        }
        return nodes;
    }

    uint256 public baseBuyTax = 5;
    uint256 public baseSellTax = 5;
    uint256 public histBinSize = 905797101;
    bool public usdtMode;
    address public uniswapV2Pair;
    address public uniswapV2PairUsdt;
    uint256 public allUserBuysTot;
    uint256 public allMarketsTot;
    mapping(address => Tree) public userBuys;
    mapping(address => Tree) public userBuysUsdt;
    mapping(address => uint256) public currentNonBuysAmount;
    mapping(address => uint256) public userBuysTot;
    struct MinutesRangeTax {
        uint256 from;
        uint256 to;
        uint256 tax;
        uint256 preScaling;
        uint256 postScaling;
    }
    mapping(uint8 => MinutesRangeTax) public minutesRangeTaxes;
    uint8 public maxIndexMinutesRange;
    uint256 basePreSellCapScaling;
    uint256 basePostSellCapScaling;
    uint256 public dynamicFloorFrac;
    uint256 public buyFeeFloorPricePerTokenE18;
    uint256 public sellCapFloorPricePerTokenE18;
    uint256 public refundPeriod;
    address private WETH_ADDRESS;
    address private USDT_ADDRESS;
    IUniswapV2Router02 private uniswapV2Router;
    address public otherOwner;
    address public externalMarkets;
    address public externalMarketsContract;
    uint256 public scalingFactor;
    uint256 priceMode;
    address public TARD_ADDRESS;
    uint256 tard_prevReservesTard;
    uint256 tard_prevReservesEth;
    uint256 tard_curReservesEth;
    uint256 tard_curReservesTard;
    uint256 usdt_curReservesUsdt;
    uint256 usdt_curReservesEth;
    uint256 usdt_prevReservesUsdt;
    uint256 usdt_prevReservesEth;
    uint256 usdtScalingFactorE18;
    uint256 prevBlockNum;
    uint256 curBlockNum;
    bool public antiFlashloanMode;
    ITardToken tardToken;
    uint256 private sumWeights;
    uint256 private weightedSum;
    bool private constant usdtPrimaryKey = true;

    constructor(
        address _WETH_ADDRESS,
        address _USDT_ADDRESS,
        IUniswapV2Router02 _uniswapV2Router,
        address _otherOwner,
        address _TARD_ADDRESS,
        uint256 _buyFeeFloorPricePerTokenE18
    ) {
        require(_WETH_ADDRESS != address(0), "ERROR_12");
        require(_USDT_ADDRESS != address(0), "ERROR_16");
        require(address(_uniswapV2Router) != address(0), "ERROR_13");
        require(address(_otherOwner) != address(0), "ERROR_14");
        require(address(_TARD_ADDRESS) != address(0), "ERROR_15");
        WETH_ADDRESS = _WETH_ADDRESS;
        USDT_ADDRESS = _USDT_ADDRESS;
        uniswapV2Router = _uniswapV2Router;
        otherOwner = _otherOwner;
        TARD_ADDRESS = _TARD_ADDRESS;
        tardToken = ITardToken(TARD_ADDRESS);
        usdtMode = true;
        usdtScalingFactorE18 = 10 ** 18;
        uniswapV2PairUsdt = IUniswapV2Factory(uniswapV2Router.factory())
            .getPair(USDT_ADDRESS, WETH_ADDRESS);
        require(address(uniswapV2PairUsdt) != address(0), "ERROR_17");
        minutesRangeTaxes[1].from = 0 minutes;
        minutesRangeTaxes[1].to = 43200 minutes;
        minutesRangeTaxes[1].tax = 30;
        minutesRangeTaxes[1].preScaling = 100;
        minutesRangeTaxes[1].postScaling = 100;
        dynamicFloorFrac = 100;
        antiFlashloanMode = true;
        maxIndexMinutesRange = 1;
        basePreSellCapScaling = 100;
        basePostSellCapScaling = 100;
        priceMode = 0;
        buyFeeFloorPricePerTokenE18 = _buyFeeFloorPricePerTokenE18;
        sellCapFloorPricePerTokenE18 = 0;
        refundPeriod = 15 minutes;
    }

    function _onlyOwnerPlus() internal view {
        require(
            (msg.sender == owner()) ||
                (msg.sender == otherOwner) ||
                (msg.sender == externalMarketsContract),
            "OWNERSHIP_ERROR_2"
        );
    }

    modifier onlyOwnerPlus() {
        _onlyOwnerPlus();
        _;
    }

    function getMvrv() public view returns (uint256 mvrvE18) {
        if (sumWeights == 0) {
            return 0;
        }
        uint256 avgPriceUsdt = weightedSum / sumWeights;
        (
            uint256 usdt_reservesUsdt,
            uint256 usdt_reservesEth
        ) = getReservesUsdt();
        uint256 usdtPerEthE18 = (usdt_reservesUsdt * 10 ** 18) /
            usdt_reservesEth;
        (uint256 tard_reservesTard, uint256 tard_reservesEth) = getReserves();
        uint256 currentPriceUsdE18 = (tard_reservesEth * usdtPerEthE18) /
            tard_reservesTard;
        return currentPriceUsdE18 / avgPriceUsdt;
    }

    function getAvgPrice() public view returns (uint256 avgPrice) {
        if (sumWeights == 0) {
            avgPrice = 0;
        } else {
            avgPrice = weightedSum / sumWeights;
        }
    }

    function appendAvgPrice(
        uint256 curWeightedSum,
        uint256 curSumWeights,
        uint256 value,
        uint256 newWeight
    ) internal pure returns (uint256 nextWeightedSum, uint256 nextSumWeights) {
        nextWeightedSum = curWeightedSum + (newWeight * value);
        nextSumWeights = curSumWeights + newWeight;
    }

    function removeAvgPrice(
        uint256 curWeightedSum,
        uint256 curSumWeights,
        uint256 value,
        uint256 oldWeight
    ) internal pure returns (uint256 nextWeightedSum, uint256 nextSumWeights) {
        nextWeightedSum = curWeightedSum > oldWeight * value
            ? curWeightedSum - (oldWeight * value)
            : 0;
        nextSumWeights = curSumWeights > oldWeight
            ? curSumWeights - oldWeight
            : 0;
    }

    function setExternalMarketsContract(
        address _externalMarketsContract
    ) external onlyOwnerPlus {
        externalMarketsContract = _externalMarketsContract;
    }

    function setUsdtMode(bool _usdtMode) external onlyOwnerPlus {
        usdtMode = _usdtMode;
    }

    function setBuyFeeFloorPricePerTokenE18(
        uint256 _buyFeeFloorPricePerTokenE18
    ) external onlyOwnerPlus {
        buyFeeFloorPricePerTokenE18 = _buyFeeFloorPricePerTokenE18;
    }

    function setBaseSellTax(uint256 _baseSellTax) external onlyOwnerPlus {
        baseSellTax = _baseSellTax;
    }

    function setTaxes2(
        uint256 _baseBuyTax,
        uint256 _baseSellTax,
        uint256 _buyFeeFloorPricePerTokenE18,
        uint256 _sellCapFloorPricePerTokenE18,
        uint256 _dynamicFloorFrac,
        uint256 _priceMode
    ) external onlyOwnerPlus {
        require(_baseBuyTax <= 10 && baseSellTax <= 5);
        baseBuyTax = _baseBuyTax;
        baseSellTax = _baseSellTax;
        buyFeeFloorPricePerTokenE18 = _buyFeeFloorPricePerTokenE18;
        sellCapFloorPricePerTokenE18 = _sellCapFloorPricePerTokenE18;
        dynamicFloorFrac = _dynamicFloorFrac;
        priceMode = _priceMode;
    }

    function getTaxes2()
        external
        view
        returns (
            uint256 s_baseBuyTax,
            uint256 s_baseSellTax,
            uint256 s_buyFeeFloorPricePerTokenE18,
            uint256 s_sellCapFloorPricePerTokenE18,
            uint256 s_dynamicFloorFrac,
            uint256 s_priceMode
        )
    {
        return (
            baseBuyTax,
            baseSellTax,
            buyFeeFloorPricePerTokenE18,
            sellCapFloorPricePerTokenE18,
            dynamicFloorFrac,
            priceMode
        );
    }

    function setAllowSome(uint256 _allowSome) public onlyOwnerPlus {
        allowSome = _allowSome;
    }

    function renounceOwnershipPlus() public virtual onlyOwnerPlus {
        emit OwnershipTransferredPlus(otherOwner, address(0));
        otherOwner = address(0);
    }

    function setRefundPeriod(uint256 _refundPeriod) external onlyOwnerPlus {
        refundPeriod = _refundPeriod;
    }

    function setMinutesRangeTax(
        uint8 _index,
        uint256 _from,
        uint256 _to,
        uint256 _tax,
        uint256 _preScaling,
        uint256 _postScaling
    ) external onlyOwnerPlus {
        minutesRangeTaxes[_index].from = _from * (1 minutes);
        minutesRangeTaxes[_index].to = _to * (1 minutes);
        minutesRangeTaxes[_index].tax = _tax;
        minutesRangeTaxes[_index].preScaling = _preScaling;
        minutesRangeTaxes[_index].postScaling = _postScaling;
    }

    function setMaxIndexMinutesRange(uint8 _maxIndex) external onlyOwnerPlus {
        maxIndexMinutesRange = _maxIndex;
    }

    function setUniswapV2Pair(address _uniswapV2Pair) external onlyOwnerPlus {
        require(_uniswapV2Pair != address(0), "ADDRESS_IS_ZERO");
        uniswapV2Pair = _uniswapV2Pair;
        initializeReserves();
    }

    function setUniswapV2PairUsdt(
        address _uniswapV2PairUsdt,
        uint256 _usdtScalingFactorE18
    ) external onlyOwnerPlus {
        require(_uniswapV2PairUsdt != address(0), "ADDRESS_IS_ZERO");
        require(_usdtScalingFactorE18 != 0, "ZERO_SCALING_FACTOR");
        uniswapV2PairUsdt = _uniswapV2PairUsdt;
        usdtScalingFactorE18 = _usdtScalingFactorE18;
        initializeReserves();
    }

    function setAntiFlashloanMode(
        bool _antiFlashloanMode
    ) external onlyOwnerPlus {
        antiFlashloanMode = _antiFlashloanMode;
    }

    function setScalingFactors(
        uint256 _basePreSellCapScaling,
        uint256 _basePostSellCapScaling
    ) external onlyOwnerPlus {
        basePreSellCapScaling = _basePreSellCapScaling;
        basePostSellCapScaling = _basePostSellCapScaling;
    }

    function _getEthFromRaising(
        uint256 reservesEth,
        uint256 reservesTard,
        uint256 amountTard
    ) public pure returns (uint256) {
        return
            reservesEth -
            ((997 * reservesTard * reservesEth) /
                (1000 * amountTard + 997 * reservesTard));
    }

    function _getEthFromLowering(
        uint256 reservesEth,
        uint256 reservesTard,
        uint256 tryTard
    ) public pure returns (uint256) {
        reservesEth *= 10 ** 18;
        uint256 amountMiddleEth = (tryTard * reservesEth * 997) /
            (reservesTard * 1000 + tryTard * 997);
        if (reservesEth <= amountMiddleEth / 10 ** 18) {
            return reservesEth;
        }
        if (reservesEth == tryTard) {
            return reservesEth;
        }
        return amountMiddleEth;
    }

    function simSwapEthToTard(
        uint256 sendEth,
        uint256 reservesTard,
        uint256 reservesEth
    )
        public
        pure
        returns (
            uint256 amountTardOut,
            uint256 nextReservesEth,
            uint256 nextReservesTard
        )
    {
        amountTardOut =
            (sendEth * reservesTard * 997) /
            (reservesEth * 1000 + sendEth * 997);
        require(reservesTard >= amountTardOut, "INSUFFICIENT_TARD_RESERVES");
        nextReservesEth = reservesEth + sendEth;
        nextReservesTard = reservesTard - amountTardOut;
        return (amountTardOut, nextReservesEth, nextReservesTard);
    }

    function clearPastBuysAmount(address sender, uint256 _amount) internal {
        uint256 remainingAmount = _amount;
        uint256 toTransfer;
        uint256 nextKey;
        (uint256 curWeightedSum, uint256 curSumWeights) = (
            weightedSum,
            sumWeights
        );
        if (remainingAmount > 0) {
            uint key = first(userBuys[sender]);
            while (key != getEmpty() && remainingAmount > 0) {
                Node memory node = getNode(userBuys[sender], key);
                toTransfer = remainingAmount > node.amount
                    ? node.amount
                    : remainingAmount;
                node.amount -= toTransfer;
                userBuysTot[sender] = userBuysTot[sender] >= toTransfer
                    ? userBuysTot[sender] - toTransfer
                    : 0;
                allUserBuysTot = allUserBuysTot >= toTransfer
                    ? allUserBuysTot - toTransfer
                    : 0;
                allMarketsTot += toTransfer;
                remainingAmount -= toTransfer;
                (curWeightedSum, curSumWeights) = removeAvgPrice(
                    curWeightedSum,
                    curSumWeights,
                    toTransfer,
                    key
                );
                nextKey = next(userBuys[sender], key);
                if (node.amount == 0) {
                    remove(userBuys[sender], key);
                }
                key = nextKey;
            }
        }
        (weightedSum, sumWeights) = (curWeightedSum, curSumWeights);
    }

    function gotBuy(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 externalPriceE18,
        uint256 useTimestamp,
        uint256 reservesTard,
        uint256 reservesEth,
        uint256 spentEth
    )
        external
        onlyOwnerPlus
        returns (
            uint256 remainingAmount,
            uint256 baseFees,
            uint256 floorFees,
            uint256 currentPriceE18,
            uint256 midPriceE18
        )
    {
        updateReserves();
        updateReserves();
        (
            ,
            uint256 higherPriceUsdtPerEthE18
        ) = getLowerHigherPriceUsdtPerEthE18ReadOnly();
        if (externalPriceE18 != 0) {
            clearPastBuysAmount(_from, _amount);
            currentPriceE18 = externalPriceE18;
            midPriceE18 = externalPriceE18;
            baseFees = 0;
            remainingAmount = _amount;
        } else {
            clearPastBuysAmount(_from, _amount);
            midPriceE18 = (spentEth * (10 ** 18)) / _amount;
            if (priceMode == 0) {
                currentPriceE18 = (reservesEth * (10 ** 18)) / reservesTard;
            } else if (priceMode == 1) {
                currentPriceE18 = (spentEth * (10 ** 18)) / _amount;
            } else {
                (spentEth, reservesEth, reservesTard) = simSwapTardToEth(
                    _amount,
                    reservesEth,
                    reservesTard
                );
                currentPriceE18 = (reservesEth * (10 ** 18)) / reservesTard;
            }
            require(currentPriceE18 != 0, "GOT_ZERO_PRICE");
            emit FloorPrice(_amount, baseBuyTax, baseFees, midPriceE18);
            baseFees = (_amount * baseBuyTax) / 100;
            remainingAmount = _amount - baseFees;
            uint256 effectivePriceE18 = (midPriceE18 * _amount) /
                remainingAmount;
            uint256 use_buyFeeFloorPricePerTokenE18;
            if (dynamicFloorFrac != 100 && buyFeeFloorPricePerTokenE18 == 0) {
                use_buyFeeFloorPricePerTokenE18 =
                    (effectivePriceE18 * dynamicFloorFrac) /
                    100;
            } else {
                use_buyFeeFloorPricePerTokenE18 = buyFeeFloorPricePerTokenE18;
            }
            uint256 floorBuyTax;
            floorFees = 0;
            if (buyFeeFloorPricePerTokenE18 > 0) {
                if (effectivePriceE18 < buyFeeFloorPricePerTokenE18) {
                    floorBuyTax =
                        (100 * (10 ** 18)) -
                        ((100 * midPriceE18 * (10 ** 18)) /
                            buyFeeFloorPricePerTokenE18) -
                        (baseBuyTax * (10 ** 18));
                    floorFees = (_amount * floorBuyTax) / (100 * (10 ** 18));
                    remainingAmount -= floorFees;
                }
                currentPriceE18 = (midPriceE18 * _amount) / remainingAmount;
                midPriceE18 = (spentEth * (10 ** 18)) / remainingAmount;
            }
            emit FloorFee(
                _amount,
                effectivePriceE18,
                buyFeeFloorPricePerTokenE18,
                floorBuyTax
            );
        }
        emit OuterSwapBuy(
            curOrderId,
            _from,
            _to,
            _amount,
            spentEth,
            remainingAmount,
            baseFees,
            floorFees,
            currentPriceE18,
            midPriceE18,
            higherPriceUsdtPerEthE18
        );
        require(
            _amount == remainingAmount + baseFees + floorFees,
            "BUY_FEES_SUM_ERROR"
        );
        while (exists(userBuys[_to], currentPriceE18)) {
            currentPriceE18 += 1;
        }
        uint256 usdtCurrentPriceE18 = (currentPriceE18 *
            higherPriceUsdtPerEthE18) / 1e18;
        uint256 key;
        if (usdtPrimaryKey) {
            key = usdtCurrentPriceE18;
        } else {
            key = currentPriceE18;
        }
        insert(
            userBuys[_to],
            key,
            useTimestamp,
            remainingAmount,
            higherPriceUsdtPerEthE18
        );
        (weightedSum, sumWeights) = appendAvgPrice(
            weightedSum,
            sumWeights,
            remainingAmount,
            usdtCurrentPriceE18
        );
        require(exists(userBuys[_to], key), "ERROR_11");
        userBuysTot[_to] += remainingAmount;
        uint256 xAmount = allMarketsTot > remainingAmount
            ? remainingAmount
            : allMarketsTot;
        allUserBuysTot += xAmount;
        allMarketsTot -= xAmount;
        return (
            remainingAmount,
            baseFees,
            floorFees,
            currentPriceE18,
            midPriceE18
        );
    }

    function getSellTaxesFine(
        uint256 buyTimestamp
    )
        public
        view
        returns (uint256 tax, uint256 preScaling, uint256 postScaling)
    {
        for (uint8 x = 1; x <= maxIndexMinutesRange; x++) {
            if (
                (buyTimestamp + minutesRangeTaxes[x].from <= block.timestamp &&
                    buyTimestamp + minutesRangeTaxes[x].to >= block.timestamp)
            ) {
                MinutesRangeTax memory taxes = minutesRangeTaxes[x];
                return (taxes.tax, taxes.preScaling, taxes.postScaling);
            }
        }
        return (baseSellTax, basePreSellCapScaling, basePostSellCapScaling);
    }

    function _getAfterCapLowering(
        uint256 reservesEth,
        uint256 reservesTard,
        uint256 tryTard,
        uint256 _CHAD_TOTAL_SUPPLY_WEI
    ) internal pure returns (uint256) {
        reservesEth *= 10 ** 18;
        uint256 amountMiddleEth = (tryTard * reservesEth * 997) /
            (reservesTard * 1000 + tryTard * 997);
        if (reservesEth <= amountMiddleEth / 10 ** 18) {
            return 0;
        }
        if (reservesEth == tryTard) {
            return 0;
        }
        return
            (((reservesEth - amountMiddleEth) / (reservesTard + tryTard)) *
                _CHAD_TOTAL_SUPPLY_WEI) / 10 ** 18;
    }

    function simSwapTardToEth(
        uint256 sendTard,
        uint256 reservesEth,
        uint256 reservesTard
    )
        public
        pure
        returns (
            uint256 amountEthOut,
            uint256 nextReservesEth,
            uint256 nextReservesTard
        )
    {
        amountEthOut =
            (sendTard * reservesEth * 997) /
            (reservesTard * 1000 + sendTard * 997);
        nextReservesEth = reservesEth - amountEthOut;
        nextReservesTard = reservesTard + sendTard;
        return (amountEthOut, nextReservesEth, nextReservesTard);
    }

    function reverseSimSwapEthToTard(
        uint256 amountTardOut,
        uint256 nextReservesEth,
        uint256 nextReservesTard
    )
        public
        pure
        returns (uint256 sentEth, uint256 reservesEth, uint256 reservesTard)
    {
        sentEth =
            (1000 * amountTardOut * nextReservesEth) /
            (1000 * amountTardOut + 997 * nextReservesTard);
        if (sentEth > nextReservesEth) {
            return (0, 0, 0);
        }
        reservesEth = nextReservesEth - sentEth;
        reservesTard = nextReservesTard + amountTardOut;
        return (sentEth, reservesEth, reservesTard);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, "ERROR_5");
        require(reserveIn > 0 && reserveOut > 0, "ERROR_6");
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut > 0, "ERROR_3");
        require(reserveIn > 0 && reserveOut > 0, "ERROR_4");
        amountIn =
            ((reserveIn * amountOut * 1000) /
                ((reserveOut - amountOut) * 997)) +
            1;
    }

    function getTardReleasableByReserves(
        uint256 tryTard,
        uint256 targetMinCapEth,
        uint256 reservesEth,
        uint256 reservesTard,
        uint256 _CHAD_TOTAL_SUPPLY_WEI,
        uint256 preCapScaling,
        uint256 postCapScaling
    ) public pure returns (uint256 chadReleasable) {
        targetMinCapEth = (targetMinCapEth * preCapScaling) / 100;
        if (targetMinCapEth == 0) {
            return (tryTard * postCapScaling) / 100;
        }
        uint256 curCapEth = _getAfterCapLowering(
            reservesEth,
            reservesTard,
            1,
            _CHAD_TOTAL_SUPPLY_WEI
        );
        if (curCapEth <= targetMinCapEth) {
            return 0;
        }
        uint256 afterCapEth = _getAfterCapLowering(
            reservesEth,
            reservesTard,
            tryTard,
            _CHAD_TOTAL_SUPPLY_WEI
        );
        if (afterCapEth >= targetMinCapEth) {
            return (tryTard * postCapScaling) / 100;
        }
        uint256 closeEnough = (targetMinCapEth * 1001) / 1000;
        uint256 left = 0;
        uint256 right = tryTard;
        while (left < right) {
            tryTard = (left + right) / 2;
            if (tryTard == 0) {
                break;
            }
            uint256 afterCapEth1 = _getAfterCapLowering(
                reservesEth,
                reservesTard,
                tryTard,
                _CHAD_TOTAL_SUPPLY_WEI
            );
            if (
                targetMinCapEth <= afterCapEth1 && afterCapEth1 <= closeEnough
            ) {
                return (tryTard * postCapScaling) / 100;
            }
            if (afterCapEth1 < targetMinCapEth) {
                right = tryTard - 1;
            } else if (afterCapEth1 > targetMinCapEth) {
                left = tryTard + 1;
            }
        }
        return (tryTard * postCapScaling) / 100;
    }

    function initializeReserves() public {
        (tard_curReservesTard, tard_curReservesEth) = getReserves();
        tard_prevReservesTard = tard_curReservesTard;
        tard_prevReservesEth = tard_curReservesEth;
        (usdt_curReservesUsdt, usdt_curReservesEth) = getReservesUsdt();
        usdt_prevReservesUsdt = usdt_curReservesUsdt;
        usdt_prevReservesEth = usdt_curReservesEth;
        curBlockNum = block.number;
        prevBlockNum = block.number;
    }

    function updateReserves() public {
        uint256 blockNum = block.number;
        if (blockNum > curBlockNum) {
            prevBlockNum = curBlockNum;
            curBlockNum = blockNum;
            tard_prevReservesEth = tard_curReservesEth;
            tard_prevReservesTard = tard_curReservesTard;
            (tard_curReservesTard, tard_curReservesEth) = getReserves();
            usdt_prevReservesUsdt = usdt_curReservesUsdt;
            usdt_prevReservesEth = usdt_curReservesEth;
            (usdt_curReservesUsdt, usdt_curReservesEth) = getReservesUsdt();
        }
    }

    function getWorseReserves(
        uint256 sendTard
    ) public returns (uint256 reservesEth, uint256 reservesTard) {
        updateReserves();
        uint256 currentPrice = simGetPostSalePrice(
            sendTard,
            tard_curReservesEth,
            tard_curReservesTard
        );
        uint256 previousPrice = simGetPostSalePrice(
            sendTard,
            tard_prevReservesEth,
            tard_prevReservesTard
        );
        if (currentPrice < previousPrice) {
            return (tard_curReservesEth, tard_curReservesTard);
        } else {
            return (tard_prevReservesEth, tard_prevReservesTard);
        }
    }

    function getLowerHigherPriceUsdtPerEthE18ReadOnly()
        public
        view
        returns (uint256 lowerPriceUsdtE18, uint256 higherPriceUsdtE18)
    {
        uint256 curPriceUsdtE18 = (usdt_curReservesUsdt * 10 ** 18) /
            usdt_curReservesEth;
        uint256 prevPriceUsdtE18 = (usdt_prevReservesUsdt * 10 ** 18) /
            usdt_prevReservesEth;
        if (curPriceUsdtE18 < prevPriceUsdtE18) {
            return (curPriceUsdtE18, prevPriceUsdtE18);
        } else {
            return (prevPriceUsdtE18, curPriceUsdtE18);
        }
    }

    function getWorseReservesReadOnly(
        uint256 sendTard
    ) public view returns (uint256 r_reservesEth, uint256 r_reservesTard) {
        uint256 blockNum = block.number;
        uint256 temp_tard_prevReservesEth = tard_prevReservesEth;
        uint256 temp_tard_prevReservesTard = tard_prevReservesTard;
        uint256 temp_tard_curReservesEth = tard_curReservesEth;
        uint256 temp_tard_curReservesTard = tard_curReservesTard;
        if (blockNum > curBlockNum) {
            (uint112 reserves0, uint112 reserves1, ) = IUniswapV2Pair(
                uniswapV2Pair
            ).getReserves();
            address token0 = IUniswapV2Pair(uniswapV2Pair).token0();
            (uint256 reservesEth, uint256 reservesTard) = token0 == TARD_ADDRESS
                ? (reserves1, reserves0)
                : (reserves0, reserves1);
            temp_tard_prevReservesEth = temp_tard_curReservesEth;
            temp_tard_prevReservesTard = temp_tard_curReservesTard;
            temp_tard_curReservesEth = reservesEth;
            temp_tard_curReservesTard = reservesTard;
        }
        uint256 currentPrice = simGetPostSalePrice(
            sendTard,
            temp_tard_curReservesEth,
            temp_tard_curReservesTard
        );
        uint256 previousPrice = simGetPostSalePrice(
            sendTard,
            temp_tard_prevReservesEth,
            temp_tard_prevReservesTard
        );
        if (currentPrice < previousPrice) {
            return (temp_tard_curReservesEth, temp_tard_curReservesTard);
        } else {
            return (temp_tard_prevReservesEth, temp_tard_prevReservesTard);
        }
    }

    function simGetPostSalePrice(
        uint256 sendTard,
        uint256 reservesEth,
        uint256 reservesTard
    ) public pure returns (uint256) {
        uint256 amountEthOut = (sendTard * reservesEth * 997) /
            (reservesTard * 1000 + sendTard * 997);
        uint256 nextReservesEth = reservesEth - amountEthOut;
        uint256 nextReservesTard = reservesTard + sendTard;
        return ((nextReservesEth * 10 ** 18) / nextReservesTard);
    }

    function getReserves()
        public
        view
        returns (uint256 reservesTard, uint256 reservesEth)
    {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(uniswapV2Pair)
            .getReserves();
        address token0 = TARD_ADDRESS < WETH_ADDRESS
            ? TARD_ADDRESS
            : WETH_ADDRESS;
        if (token0 == TARD_ADDRESS) {
            (reservesTard, reservesEth) = (reserve0, reserve1);
        } else {
            (reservesTard, reservesEth) = (reserve1, reserve0);
        }
    }

    function getReservesUsdt()
        public
        view
        returns (uint256 reservesUsdt, uint256 reservesEth)
    {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            uniswapV2PairUsdt
        ).getReserves();
        address token0 = USDT_ADDRESS < WETH_ADDRESS
            ? USDT_ADDRESS
            : WETH_ADDRESS;
        require(reserve0 != 0 && reserve1 != 0, "USDT_RESERVES_ZERO");
        if (token0 == USDT_ADDRESS) {
            (reservesUsdt, reservesEth) = (reserve0, reserve1);
        } else {
            (reservesUsdt, reservesEth) = (reserve1, reserve0);
        }
        reservesEth = (reservesEth * usdtScalingFactorE18) / 10 ** 18;
    }

    function checkNodeTotal(
        address _to,
        uint256 expectedAmount
    ) external view returns (uint256 totAmount) {
        uint key = first(userBuys[_to]);
        while (key != getEmpty()) {
            Node memory node = getNode(userBuys[_to], key);
            totAmount += node.amount;
            key = next(userBuys[_to], key);
        }
        require(totAmount == expectedAmount, "TOT_AMOUNT_NOT_EXPECTED_AMOUNT");
    }

    function getNodeTotal(
        address _to
    ) external view returns (uint256 totAmount) {
        uint key = first(userBuys[_to]);
        while (key != getEmpty()) {
            Node memory node = getNode(userBuys[_to], key);
            totAmount += node.amount;
            key = next(userBuys[_to], key);
        }
        return totAmount;
    }

    function getNodes(
        address _to
    ) external view returns (NodeInfo[] memory nodeInfos) {
        nodeInfos = new NodeInfo[](userBuys[_to].nodesCount);
        uint256 nodeInfosIndex = 0;
        uint key = first(userBuys[_to]);
        while (key != getEmpty()) {
            Node memory node = getNode(userBuys[_to], key);
            NodeInfo memory nodeInfo;
            nodeInfo.key = key;
            nodeInfo.timestamp = node.timestamp;
            nodeInfo.amount = node.amount;
            nodeInfo.usdPerEth = node.usdPerEth;
            nodeInfos[nodeInfosIndex++] = nodeInfo;
            key = next(userBuys[_to], key);
        }
        return (nodeInfos);
    }

    function simGotBuy(
        address _to,
        uint256 _amount,
        uint256 externalPriceE18,
        bool inputIsEth
    )
        external
        view
        returns (
            uint256 preReservesEth,
            uint256 preReservesTard,
            uint256 reservesEth,
            uint256 reservesTard,
            uint256 requestedAmount,
            uint256 remainingAmount,
            uint256 baseFees,
            uint256 floorFees,
            uint256 spentEth,
            uint256 currentPriceE18,
            uint256 midPriceE18,
            uint256 _priceMode,
            uint256 _buyFeeFloorPricePerTokenE18,
            uint256 _baseBuyTax,
            NodeInfo[] memory nodeInfos
        )
    {
        (preReservesTard, preReservesEth) = getReserves();
        reservesEth = preReservesEth;
        reservesTard = preReservesTard;
        if (inputIsEth) {
            spentEth = _amount;
            _amount = getAmountOut(spentEth, reservesEth, reservesTard);
        } else {
            spentEth = getAmountIn(_amount, reservesEth, reservesTard);
        }
        nodeInfos = new NodeInfo[](userBuys[_to].nodesCount);
        uint256 nodeInfosIndex = 0;
        if (externalPriceE18 != 0) {
            currentPriceE18 = externalPriceE18;
            midPriceE18 = externalPriceE18;
            baseFees = 0;
            remainingAmount = _amount;
        } else {
            midPriceE18 = (spentEth * (10 ** 18)) / _amount;
            if (priceMode == 0) {
                currentPriceE18 = (reservesEth * (10 ** 18)) / reservesTard;
            } else if (priceMode == 1) {
                currentPriceE18 = (spentEth * (10 ** 18)) / _amount;
            } else {
                (
                    ,
                    uint256 reservesEth2,
                    uint256 reservesTard2
                ) = simSwapTardToEth(_amount, reservesEth, reservesTard);
                currentPriceE18 = (reservesEth2 * (10 ** 18)) / reservesTard2;
            }
            require(currentPriceE18 != 0, "GOT_ZERO_PRICE");
            baseFees = (_amount * baseBuyTax) / 100;
            remainingAmount = _amount - baseFees;
            uint256 effectivePriceE18 = (midPriceE18 * _amount) /
                remainingAmount;
            uint256 use_buyFeeFloorPricePerTokenE18;
            if (dynamicFloorFrac != 100 && buyFeeFloorPricePerTokenE18 == 0) {
                use_buyFeeFloorPricePerTokenE18 =
                    (effectivePriceE18 * dynamicFloorFrac) /
                    100;
            } else {
                use_buyFeeFloorPricePerTokenE18 = buyFeeFloorPricePerTokenE18;
            }
            uint256 floorBuyTax;
            floorFees = 0;
            if (use_buyFeeFloorPricePerTokenE18 > 0) {
                if (effectivePriceE18 < use_buyFeeFloorPricePerTokenE18) {
                    floorBuyTax =
                        (100 * (10 ** 18)) -
                        ((100 * midPriceE18 * (10 ** 18)) /
                            use_buyFeeFloorPricePerTokenE18) -
                        (baseBuyTax * (10 ** 18));
                    floorFees = (_amount * floorBuyTax) / (100 * (10 ** 18));
                    remainingAmount -= floorFees;
                }
                currentPriceE18 = (midPriceE18 * _amount) / remainingAmount;
                midPriceE18 = (spentEth * (10 ** 18)) / remainingAmount;
            }
        }
        require(
            _amount == remainingAmount + baseFees + floorFees,
            "BUY_FEES_SUM_ERROR"
        );
        while (exists(userBuys[_to], currentPriceE18)) {
            currentPriceE18 += 1;
        }
        (
            ,
            uint256 nextReservesEth,
            uint256 nextReservesTard
        ) = simSwapEthToTard(spentEth, reservesTard, reservesEth);
        uint key = first(userBuys[_to]);
        while (key != getEmpty()) {
            Node memory node = getNode(userBuys[_to], key);
            NodeInfo memory nodeInfo;
            nodeInfo.key = key;
            nodeInfo.timestamp = node.timestamp;
            nodeInfo.amount = node.amount;
            nodeInfos[nodeInfosIndex++] = nodeInfo;
            key = next(userBuys[_to], key);
        }
        return (
            preReservesEth,
            preReservesTard,
            nextReservesEth,
            nextReservesTard,
            _amount,
            remainingAmount,
            baseFees,
            floorFees,
            spentEth,
            currentPriceE18,
            midPriceE18,
            priceMode,
            buyFeeFloorPricePerTokenE18,
            baseBuyTax,
            nodeInfos
        );
    }

    function gotTransfer(
        uint256 curOrderId,
        address sender,
        address _to,
        uint256 _amount,
        uint256 senderBalance
    ) external onlyOwnerPlus returns (uint256 allowAmount) {
        uint256 untrackedAmount;
        uint256 remainingAmount = _amount;
        uint256 toTransfer;
        uint256 nextKey;
        uint256 higherPriceUsdtPerEthE18;
        if (usdtPrimaryKey) {
            updateReserves();
            (
                ,
                higherPriceUsdtPerEthE18
            ) = getLowerHigherPriceUsdtPerEthE18ReadOnly();
        }
        if (remainingAmount > 0) {
            uint key = first(userBuys[sender]);
            while (key != getEmpty() && remainingAmount > 0) {
                Node memory node = getNode(userBuys[sender], key);
                toTransfer = remainingAmount > node.amount
                    ? node.amount
                    : remainingAmount;
                node.amount -= toTransfer;
                userBuysTot[sender] = userBuysTot[sender] >= toTransfer
                    ? userBuysTot[sender] - toTransfer
                    : 0;
                allUserBuysTot = allUserBuysTot >= toTransfer
                    ? allUserBuysTot - toTransfer
                    : 0;
                allMarketsTot += toTransfer;
                allowAmount += toTransfer;
                remainingAmount -= toTransfer;
                insert(
                    userBuys[_to],
                    key,
                    node.timestamp,
                    toTransfer,
                    node.usdPerEth
                );
                nextKey = next(userBuys[sender], key);
                if (node.amount == 0) {
                    remove(userBuys[sender], key);
                }
                emit InnerSwapTransfer(curOrderId, key, toTransfer);
                key = nextKey;
            }
            if (senderBalance > userBuysTot[sender]) {
                untrackedAmount = senderBalance - userBuysTot[sender];
                toTransfer = untrackedAmount >= remainingAmount
                    ? remainingAmount
                    : untrackedAmount;
                allowAmount += toTransfer;
                remainingAmount -= toTransfer;
                emit InnerSwapTransfer(curOrderId, 0, toTransfer);
            }
            emit OuterSwapTransfer(
                curOrderId,
                sender,
                _to,
                _amount,
                senderBalance,
                allowAmount,
                remainingAmount
            );
        }
        return _amount;
    }

    function simGotSell(
        uint256,
        address sender,
        uint256 _amount
    )
        external
        view
        returns (
            uint256 allowAmount,
            uint256 fees,
            uint256 rewardTokens,
            uint256 totEthOut,
            uint256 midPriceE18,
            uint256 preReservesTard,
            uint256 preReservesEth,
            uint256 reservesTard,
            uint256 reservesEth,
            uint256 _baseSellTax,
            uint256 _senderInitialBuyTimestamp,
            uint256 _senderBalance,
            uint256 untrackedAmount,
            bool _usdtMode,
            uint256 lowerPriceUsdtPerEthE18,
            NodeInfo[] memory nodeInfos
        )
    {
        uint256 senderInitialBuyTimestamp = tardToken.initialBuyTimestamp(
            sender
        );
        uint256 senderBalance = tardToken.balanceOf(sender);
        if (antiFlashloanMode) {
            (preReservesEth, preReservesTard) = getWorseReservesReadOnly(
                _amount
            );
        } else {
            (preReservesTard, preReservesEth) = getReserves();
        }
        if (usdtPrimaryKey || usdtMode) {
            (
                lowerPriceUsdtPerEthE18,

            ) = getLowerHigherPriceUsdtPerEthE18ReadOnly();
        }
        reservesTard = preReservesTard;
        reservesEth = preReservesEth;
        require(reservesEth > 0, "RESERVES_ETH_ZERO");
        uint256 remainingAmount = _amount;
        uint256 allowedFromNode;
        uint256 amountEthOut;
        uint256 tax;
        uint256 preCapScaling;
        uint256 postCapScaling;
        nodeInfos = new NodeInfo[](userBuys[sender].nodesCount);
        uint256 nodeInfosIndex = 0;
        (tax, preCapScaling, postCapScaling) = getSellTaxesFine(
            senderInitialBuyTimestamp
        );
        if (senderBalance > userBuysTot[sender]) {
            untrackedAmount = senderBalance - userBuysTot[sender];
            allowedFromNode = getTardReleasableByReserves(
                untrackedAmount,
                sellCapFloorPricePerTokenE18,
                reservesEth,
                reservesTard,
                10 ** 18,
                preCapScaling,
                postCapScaling
            );
            (amountEthOut, reservesEth, reservesTard) = simSwapTardToEth(
                allowedFromNode,
                reservesEth,
                reservesTard
            );
            totEthOut += amountEthOut;
            uint256 toTransfer = remainingAmount > allowedFromNode
                ? allowedFromNode
                : remainingAmount;
            uint256 currentFees = (toTransfer * tax) / 100;
            uint256 currentRewardTokens = (toTransfer * (tax - baseSellTax)) /
                100;
            fees += currentFees;
            rewardTokens += currentRewardTokens;
            allowAmount += toTransfer - currentFees;
            remainingAmount -= toTransfer;
        }
        uint256 use_key;
        uint256 use_reservesEth;
        uint256 availableInNode0;
        bool isFirst = true;
        if (remainingAmount > 0) {
            uint key = first(userBuys[sender]);
            while (key != getEmpty() && remainingAmount > 0) {
                Node memory node = getNode(userBuys[sender], key);
                use_key = key;
                if (isFirst) {
                    availableInNode0 = node.amount;
                }
                if (usdtPrimaryKey) {
                    use_reservesEth =
                        (reservesEth * lowerPriceUsdtPerEthE18) /
                        1e18;
                }
                (tax, preCapScaling, postCapScaling) = getSellTaxesFine(
                    node.timestamp
                );
                if (block.timestamp - node.timestamp < refundPeriod) {
                    allowedFromNode = node.amount;
                    uint256 temp_allowedFromNode = getTardReleasableByReserves(
                        node.amount,
                        use_key,
                        use_reservesEth,
                        reservesTard,
                        10 ** 18,
                        preCapScaling,
                        postCapScaling
                    );
                    (
                        amountEthOut,
                        reservesEth,
                        reservesTard
                    ) = simSwapTardToEth(
                        temp_allowedFromNode,
                        reservesEth,
                        reservesTard
                    );
                    totEthOut += amountEthOut;
                } else {
                    allowedFromNode = getTardReleasableByReserves(
                        node.amount,
                        use_key,
                        use_reservesEth,
                        reservesTard,
                        10 ** 18,
                        preCapScaling,
                        postCapScaling
                    );
                    (
                        amountEthOut,
                        reservesEth,
                        reservesTard
                    ) = simSwapTardToEth(
                        allowedFromNode,
                        reservesEth,
                        reservesTard
                    );
                    totEthOut += amountEthOut;
                }
                if (allowedFromNode == 0) {
                    NodeInfo memory nodeInfo1;
                    nodeInfo1.key = key;
                    nodeInfo1.timestamp = node.timestamp;
                    nodeInfo1.amount = node.amount;
                    nodeInfos[nodeInfosIndex++] = nodeInfo1;
                    break;
                }
                uint256 toTransfer = remainingAmount > allowedFromNode
                    ? allowedFromNode
                    : remainingAmount;
                uint256 currentFees = (toTransfer * tax) / 100;
                uint256 currentRewardTokens = (toTransfer *
                    (tax - baseSellTax)) / 100;
                fees += currentFees;
                rewardTokens += currentRewardTokens;
                allowAmount += toTransfer - currentFees;
                remainingAmount -= toTransfer;
                NodeInfo memory nodeInfo;
                nodeInfo.key = key;
                nodeInfo.timestamp = node.timestamp;
                nodeInfo.amount = node.amount;
                nodeInfo.allowedFromNode = allowedFromNode;
                nodeInfo.currentFees = currentFees;
                nodeInfo.currentRewardTokens = currentRewardTokens;
                nodeInfos[nodeInfosIndex++] = nodeInfo;
                key = next(userBuys[sender], key);
                isFirst = false;
            }
        }
        if (allowAmount > 0) {
            midPriceE18 = (totEthOut * 10 ** 18) / (allowAmount);
        }
        uint256 actualSize = nodeInfosIndex;
        if (actualSize < userBuys[sender].nodesCount) {
            NodeInfo[] memory resizedNodeInfos = new NodeInfo[](actualSize);
            for (uint256 i = 0; i < actualSize; i++) {
                resizedNodeInfos[i] = nodeInfos[i];
            }
            nodeInfos = resizedNodeInfos;
        }
        return (
            allowAmount,
            fees,
            rewardTokens,
            totEthOut,
            midPriceE18,
            preReservesTard,
            preReservesEth,
            reservesTard,
            reservesEth,
            baseSellTax,
            senderInitialBuyTimestamp,
            senderBalance,
            untrackedAmount,
            usdtMode,
            lowerPriceUsdtPerEthE18,
            nodeInfos
        );
    }

    function gotSell(
        uint256 curOrderId,
        address sender,
        address receiver,
        uint256 _amount,
        uint256 senderInitialBuyTimestamp,
        uint256 senderBalance
    )
        external
        onlyOwnerPlus
        returns (
            uint256 allowAmount,
            uint256 fees,
            uint256 rewardTokens,
            uint256 totEthOut,
            uint256 midPriceE18
        )
    {
        uint256 reservesTard;
        uint256 reservesEth;
        (uint256 curWeightedSum, uint256 curSumWeights) = (
            weightedSum,
            sumWeights
        );
        if (antiFlashloanMode) {
            (reservesEth, reservesTard) = getWorseReserves(_amount);
        } else {
            (reservesTard, reservesEth) = getReserves();
        }
        uint256 lowerPriceUsdtPerEthE18;
        if (usdtPrimaryKey || usdtMode) {
            updateReserves();
            (
                lowerPriceUsdtPerEthE18,

            ) = getLowerHigherPriceUsdtPerEthE18ReadOnly();
        }
        require(reservesEth > 0, "RESERVES_ETH_ZERO");
        uint256 remainingAmount = _amount;
        uint256 allowedFromNode;
        uint256 tax;
        uint256 preCapScaling;
        uint256 postCapScaling;
        (tax, preCapScaling, postCapScaling) = getSellTaxesFine(
            senderInitialBuyTimestamp
        );
        uint256 amountEthOut;
        if (senderBalance > userBuysTot[sender]) {
            uint256 untrackedAmount = senderBalance - userBuysTot[sender];
            allowedFromNode = getTardReleasableByReserves(
                untrackedAmount,
                sellCapFloorPricePerTokenE18,
                reservesEth,
                reservesTard,
                10 ** 18,
                preCapScaling,
                postCapScaling
            );
            (amountEthOut, reservesEth, reservesTard) = simSwapTardToEth(
                allowedFromNode,
                reservesEth,
                reservesTard
            );
            totEthOut += amountEthOut;
            uint256 toTransfer = remainingAmount > allowedFromNode
                ? allowedFromNode
                : remainingAmount;
            uint256 currentFees = (toTransfer * tax) / 100;
            uint256 currentRewardTokens = (toTransfer * (tax - baseSellTax)) /
                100;
            fees += currentFees;
            rewardTokens += currentRewardTokens;
            allowAmount += toTransfer - currentFees;
            remainingAmount -= toTransfer;
            emit InnerSwapSell(
                curOrderId,
                0,
                toTransfer - currentFees,
                currentFees,
                currentRewardTokens
            );
        }
        uint256 use_key;
        uint256 use_reservesEth;
        uint256 availableInNode0;
        bool isFirst = true;
        uint256 nextKey;
        if (remainingAmount > 0) {
            uint key = first(userBuys[sender]);
            while (key != getEmpty() && remainingAmount > 0) {
                Node storage node = getNodeStorage(userBuys[sender], key);
                use_key = key;
                if (isFirst) {
                    availableInNode0 = node.amount;
                }
                if (usdtPrimaryKey) {
                    use_reservesEth =
                        (reservesEth * lowerPriceUsdtPerEthE18) /
                        1e18;
                }
                (tax, preCapScaling, postCapScaling) = getSellTaxesFine(
                    node.timestamp
                );
                if (block.timestamp - node.timestamp < refundPeriod) {
                    allowedFromNode = node.amount;
                    uint256 temp_allowedFromNode = getTardReleasableByReserves(
                        node.amount,
                        use_key,
                        use_reservesEth,
                        reservesTard,
                        10 ** 18,
                        preCapScaling,
                        postCapScaling
                    );
                    (
                        amountEthOut,
                        reservesEth,
                        reservesTard
                    ) = simSwapTardToEth(
                        temp_allowedFromNode,
                        reservesEth,
                        reservesTard
                    );
                    totEthOut += amountEthOut;
                } else {
                    allowedFromNode = getTardReleasableByReserves(
                        node.amount,
                        use_key,
                        use_reservesEth,
                        reservesTard,
                        10 ** 18,
                        preCapScaling,
                        postCapScaling
                    );
                    (
                        amountEthOut,
                        reservesEth,
                        reservesTard
                    ) = simSwapTardToEth(
                        allowedFromNode,
                        reservesEth,
                        reservesTard
                    );
                    totEthOut += amountEthOut;
                }
                if (allowedFromNode == 0) {
                    break;
                }
                uint256 toTransfer = remainingAmount > allowedFromNode
                    ? allowedFromNode
                    : remainingAmount;
                node.amount -= toTransfer;
                userBuysTot[sender] = userBuysTot[sender] >= toTransfer
                    ? userBuysTot[sender] - toTransfer
                    : 0;
                allUserBuysTot = allUserBuysTot >= toTransfer
                    ? allUserBuysTot - toTransfer
                    : 0;
                allMarketsTot += toTransfer;
                uint256 currentFees = (toTransfer * tax) / 100;
                uint256 currentRewardTokens = (toTransfer *
                    (tax - baseSellTax)) / 100;
                fees += currentFees;
                rewardTokens += currentRewardTokens;
                allowAmount += toTransfer - currentFees;
                remainingAmount -= toTransfer;
                emit InnerSwapSell(
                    curOrderId,
                    key,
                    toTransfer - currentFees,
                    currentFees,
                    currentRewardTokens
                );
                nextKey = next(userBuys[sender], key);
                if (node.amount == 0) {
                    remove(userBuys[sender], key);
                }
                (curWeightedSum, curSumWeights) = removeAvgPrice(
                    curWeightedSum,
                    curSumWeights,
                    toTransfer,
                    key
                );
                key = nextKey;
                isFirst = false;
            }
        }
        (weightedSum, sumWeights) = (curWeightedSum, curSumWeights);
        if (allowAmount > 0) {
            midPriceE18 = (totEthOut * 10 ** 18) / (allowAmount);
        }
        require(allowAmount > 0, "MARKET PRICE BELOW YOUR BUY-IN PRICE.");
        emit OuterSwapSell(
            curOrderId,
            sender,
            receiver,
            _amount,
            allowAmount,
            fees,
            rewardTokens,
            totEthOut,
            midPriceE18,
            sellCapFloorPricePerTokenE18
        );
        return (allowAmount, fees, rewardTokens, totEthOut, midPriceE18);
    }
}

contract TardDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private tokenHoldersCount;
    mapping(address => bool) private tokenHoldersMap;
    mapping(address => bool) public excludedFromDividends;
    uint256 public immutable minimumTokenBalanceForDividends;
    event ExcludeFromDividends(address indexed account);

    constructor()
        DividendPayingToken("Tard_Dividend_Tracker", "Tard_Dividend_Tracker")
    {
        minimumTokenBalanceForDividends = 10000 * 10 ** 9;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function _approve(address, address, uint256) internal pure override {
        require(false, "Tard_Dividend_Tracker: No approvals allowed");
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Tard_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "Tard_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main Tard contract."
        );
    }

    function excludeFromDividends(address account) external onlyOwner {
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        if (tokenHoldersMap[account] == true) {
            tokenHoldersMap[account] = false;
            tokenHoldersCount.decrement();
        }
        emit ExcludeFromDividends(account);
    }

    function includeFromDividends(
        address account,
        uint256 balance
    ) external onlyOwner {
        excludedFromDividends[account] = false;
        if (balance >= minimumTokenBalanceForDividends) {
            _setBalance(account, balance);
            if (tokenHoldersMap[account] == false) {
                tokenHoldersMap[account] = true;
                tokenHoldersCount.increment();
            }
        }
        emit ExcludeFromDividends(account);
    }

    function isExcludeFromDividends(
        address account
    ) external view onlyOwner returns (bool) {
        return excludedFromDividends[account];
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersCount.current();
    }

    function setBalance(
        address payable account,
        uint256 newBalance
    ) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }
        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            if (tokenHoldersMap[account] == false) {
                tokenHoldersMap[account] = true;
                tokenHoldersCount.increment();
            }
        } else {
            _setBalance(account, 0);
            if (tokenHoldersMap[account] == true) {
                tokenHoldersMap[account] = false;
                tokenHoldersCount.decrement();
            }
        }
    }

    function processAccount(
        address account,
        address toAccount
    ) public onlyOwner returns (uint256) {
        uint256 amount = _withdrawDividendOfUser(
            payable(account),
            payable(toAccount)
        );
        return amount;
    }

    function emergencyWithdraw(address _receiver) external onlyOwner {
        magnifiedDividendPerShare = 0;
        uint256 totalBalance = address(this).balance;
        require(totalBalance > 0, "no balance");
        (bool success, ) = _receiver.call{value: totalBalance}("");
        require(success);
    }
}

contract Tcoin is ERC20, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    bool public revokeSetBots;
    string private constant _name = "Test";
    string private constant _symbol = "TEST";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1e12 * 1e9;
    IUniswapV2Router02 private uniswapV2Router;
    bool public tradingOpen = false;
    address private uniswapV2Pair;
    uint256 orderIdSeq;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public isExcludeFromFee;
    mapping(address => bool) public isBot;
    mapping(address => bool) public externalMarkets;
    mapping(address => uint256) public initialBuyTimestamp;
    uint256 private walletLimitPercentage = 100;
    mapping(address => bool) public isExcludeFromWalletLimit;
    uint256 private autoLP = 0;
    uint256 private devFee = 50;
    uint256 private marketingFee = 50;
    uint256 public minContractTokensToSwap = 2e9 * 10 ** 9;
    bool public swapAll = false;
    address private devWalletAddress;
    address private marketingWalletAddress;
    TardIncentivesTracker public incentivesTracker;
    TardDividendTracker public dividendTracker;
    uint256 minimumTokenBalanceForDividends = 10000 * 10 ** 9;
    mapping(address => uint256) public lastTransfer;
    uint256 public pendingTokensForReward;
    uint256 public minRewardTokensToSwap = 10000 * 10 ** 9;
    uint256 public pendingEthReward;
    struct ClaimedEth {
        uint256 ethAmount;
        uint256 tokenAmount;
        uint256 timestamp;
    }
    Counters.Counter private claimedHistoryIds;
    mapping(uint256 => ClaimedEth) private claimedEthMap;
    mapping(address => uint256[]) private userClaimedIds;
    event BuyFees(
        address from,
        address to,
        uint256 received,
        uint256 baseFeesTokens,
        uint256 floorFeesTokens
    );
    event SellFees(address from, address to, uint256 received, uint256 fees);
    event AddLiquidity(uint256 amountTokens, uint256 amountEth);
    event SwapTokensForEth(uint256 sentTokens, uint256 receivedEth);
    event SwapEthForTokens(uint256 sentEth, uint256 receivedTokens);
    event DistributeFees(uint256 devEth, uint256 remarketingEth);
    event AddRewardPool(uint256 _ethAmount);
    event SendDividends(uint256 amount);
    event GotBuy(
        uint256 externalPriceE18,
        uint256 _amount,
        uint256 reservesEth,
        uint256 reservesTard,
        uint256 remainingAmount,
        uint256 baseFees,
        uint256 floorFees,
        uint256 spentEth,
        uint256 currentPriceE18,
        uint256 midPriceE18,
        uint256 startingPriceE18,
        uint256 startingMidPriceE18
    );
    event GotSell(
        uint256 originalAmount,
        uint256 remainingAmount,
        uint256 fees,
        uint256 rewardTokens,
        uint256 totEthOut,
        uint256 midPriceE18
    );
    event FromExternalPriceAddress(
        address _from,
        address _to,
        uint256 externalPriceE18,
        uint256 _amount,
        uint256 transferAmount
    );
    event DividendClaimed(
        uint256 ethAmount,
        uint256 tokenAmount,
        address account
    );
    event ExpectedSpentEth(
        uint256 spentEth,
        uint256 _amount,
        uint256 reservesEth,
        uint256 reservesTard
    );
    event BeforeSellStats(
        uint256 _amount,
        uint256 gotUserBuysTot,
        uint256 senderBalance
    );
    event GotTransfer(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 senderBalance,
        uint256 transferAmount
    );
    event TakeFees(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 transferAmount,
        uint256 externalPriceE18
    );
    address public tardHelper;
    modifier onlyHelper() {
        require(
            address(tardHelper) == msg.sender || owner() == msg.sender,
            "OWNERSHIP_ERROR_3"
        );
        _;
    }
    address public WETH_ADDRESS;
    address public uniswapV2PairUsdtAddress;

    constructor(
        address _USDT_ADDRESS,
        address _uniswapV2RouterAddress,
        address _devWalletAddress,
        address _marketingWalletAddress,
        uint256 _buyFeeFloorPricePerTokenE18
    ) ERC20(_name, _symbol) {
        require(_uniswapV2RouterAddress != address(0), "ROUTER_IS_ZERO");
        if (
            _uniswapV2RouterAddress ==
            address(0x98bf93ebf5c380C0e6Ae8e192A7e2AE08edAcc02)
        ) {
            uniswapV2Router = IUniswapV2Router02(_uniswapV2RouterAddress);
            WETH_ADDRESS = uniswapV2Router.WPLS();
        } else {
            uniswapV2Router = IUniswapV2Router02(_uniswapV2RouterAddress);
            WETH_ADDRESS = uniswapV2Router.WETH();
        }
        require(WETH_ADDRESS != address(0), "WETH_ADDRESS_IS_ZERO");
        devWalletAddress = _devWalletAddress;
        marketingWalletAddress = _marketingWalletAddress;
        isExcludeFromFee[owner()] = true;
        isExcludeFromFee[address(this)] = true;
        isExcludeFromWalletLimit[owner()] = true;
        isExcludeFromWalletLimit[address(this)] = true;
        isExcludeFromWalletLimit[address(uniswapV2Router)] = true;
        uniswapV2PairUsdtAddress = address(
            IUniswapV2Factory(uniswapV2Router.factory()).getPair(
                _USDT_ADDRESS,
                WETH_ADDRESS
            )
        );
        incentivesTracker = new TardIncentivesTracker(
            WETH_ADDRESS,
            _USDT_ADDRESS,
            uniswapV2Router,
            msg.sender,
            address(this),
            _buyFeeFloorPricePerTokenE18
        );
        dividendTracker = new TardDividendTracker();
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(
            address(0x0000000000000000000000000000000000000369)
        );
        _mint(owner(), _tTotal);
    }

    function getNodesRange(
        address user,
        uint256 _limit,
        uint256 _pageNumber
    ) external view returns (TardIncentivesTracker.Node[] memory) {
        return
            incentivesTracker.externalGetNodesRange(user, _limit, _pageNumber);
    }

    function setTardIncentivesTracker(
        address _incentivesTracker
    ) external onlyOwner {
        incentivesTracker = TardIncentivesTracker(_incentivesTracker);
    }

    function setTardHelper(address _tardHelper) external onlyOwner {
        tardHelper = _tardHelper;
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                WETH_ADDRESS
            );
        incentivesTracker.setUniswapV2Pair(address(uniswapV2Pair));
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        dividendTracker.excludeFromDividends(uniswapV2Pair);
        addLiquidity(balanceOf(address(this)), address(this).balance);
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
        tradingOpen = true;
    }

    function manualSwap() external onlyOwner {
        uint256 totalTokens = balanceOf(address(this)).sub(
            pendingTokensForReward
        );
        swapTokensForEth(totalTokens);
    }

    function manualSend() external onlyOwner {
        uint256 totalEth = address(this).balance.sub(pendingEthReward);
        uint256 devFeesToSend = totalEth.mul(devFee).div(
            uint256(100).sub(autoLP)
        );
        uint256 marketingFeesToSend = totalEth.mul(marketingFee).div(
            uint256(100).sub(autoLP)
        );
        uint256 remainingEthForFees = totalEth.sub(devFeesToSend).sub(
            marketingFeesToSend
        );
        devFeesToSend = devFeesToSend.add(remainingEthForFees);
        sendEthToWallets(devFeesToSend, marketingFeesToSend);
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(
        address _account
    ) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(_account);
    }

    function dividendTokenBalanceOf(
        address _account
    ) public view returns (uint256) {
        return dividendTracker.balanceOf(_account);
    }

    function claim() external {
        _claim(payable(msg.sender), false);
    }

    function reinvest() external {
        _claim(payable(msg.sender), true);
    }

    function _claim(address payable _account, bool _reinvest) private {
        uint256 withdrawableAmount = dividendTracker.withdrawableDividendOf(
            _account
        );
        require(withdrawableAmount > 0, "Claimer has no withdrawable dividend");
        uint256 ethAmount;
        uint256 tokenAmount;
        if (!_reinvest) {
            ethAmount = dividendTracker.processAccount(_account, _account);
        } else {
            ethAmount = dividendTracker.processAccount(_account, address(this));
            if (ethAmount > 0) {
                tokenAmount = swapEthForTokens(ethAmount, _account);
            }
        }
        if (ethAmount > 0) {
            claimedHistoryIds.increment();
            uint256 hId = claimedHistoryIds.current();
            claimedEthMap[hId].ethAmount = ethAmount;
            claimedEthMap[hId].tokenAmount = tokenAmount;
            claimedEthMap[hId].timestamp = block.timestamp;
            userClaimedIds[_account].push(hId);
            emit DividendClaimed(ethAmount, tokenAmount, _account);
        }
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getAccount(
        address _account
    )
        public
        view
        returns (
            uint256 withdrawableDividends,
            uint256 withdrawnDividends,
            uint256 balance
        )
    {
        (withdrawableDividends, withdrawnDividends) = dividendTracker
            .getAccount(_account);
        return (withdrawableDividends, withdrawnDividends, balanceOf(_account));
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function buyPricedDelegated(
        address _from,
        address _to,
        uint256 _amount,
        uint256 externalPriceE18
    ) public onlyOwner {
        require(externalMarkets[_from], "NOT_ALLOWED_MINTER");
        require(externalPriceE18 != 0, "EXTERNAL_PRICE_IS_ZERO");
        _transferInner(_from, _to, _amount, externalPriceE18);
    }

    function buyPriced(
        address _to,
        uint256 _amount,
        uint256 externalPriceE18
    ) public {
        address _from = _msgSender();
        require(externalMarkets[_from], "NOT_ALLOWED_MINTER");
        require(externalPriceE18 != 0, "EXTERNAL_PRICE_IS_ZERO");
        _transferInner(_from, _to, _amount, externalPriceE18);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        _transferInner(_from, _to, _amount, 0);
    }

    function _transferInner(
        address _from,
        address _to,
        uint256 _amount,
        uint256 externalPriceE18
    ) internal {
        require(!isBot[_from] && !isBot[_to]);
        uint256 transferAmount = _amount;
        uint256 prevWalletLimit = walletLimitPercentage;
        uint256 curOrderId = orderIdSeq++;
        if (externalPriceE18 != 0) {
            transferAmount = takeFees(
                curOrderId,
                _from,
                _to,
                _amount,
                externalPriceE18
            );
            emit FromExternalPriceAddress(
                _from,
                _to,
                _amount,
                externalPriceE18,
                transferAmount
            );
        } else if (
            tradingOpen &&
            (automatedMarketMakerPairs[_from] ||
                automatedMarketMakerPairs[_to]) &&
            !isExcludeFromFee[_from] &&
            !isExcludeFromFee[_to]
        ) {
            transferAmount = takeFees(curOrderId, _from, _to, _amount, 0);
            emit TakeFees(
                curOrderId,
                _from,
                _to,
                _amount,
                transferAmount,
                externalPriceE18
            );
        } else if (tradingOpen) {
            transferAmount = incentivesTracker.gotTransfer(
                curOrderId,
                _from,
                _to,
                _amount,
                balanceOf(_from)
            );
            emit GotTransfer(
                curOrderId,
                _from,
                _to,
                _amount,
                balanceOf(_from),
                transferAmount
            );
        }
        if (initialBuyTimestamp[_to] == 0) {
            initialBuyTimestamp[_to] = block.timestamp;
        }
        if (externalPriceE18 == 0) {
            if (
                !automatedMarketMakerPairs[_to] &&
                !isExcludeFromWalletLimit[_to]
            ) {
                uint256 addressBalance = balanceOf(_to).add(transferAmount);
                require(
                    addressBalance <=
                        totalSupply().mul(walletLimitPercentage).div(10000),
                    "Wallet balance limit reached"
                );
            }
        }
        super._transfer(_from, _to, transferAmount);
        walletLimitPercentage = prevWalletLimit;
        if (!dividendTracker.isExcludeFromDividends(_from)) {
            try
                dividendTracker.setBalance(payable(_from), balanceOf(_from))
            {} catch {}
        }
        if (!dividendTracker.isExcludeFromDividends(_to)) {
            try
                dividendTracker.setBalance(payable(_to), balanceOf(_to))
            {} catch {}
        }
    }

    function _setAutomatedMarketMakerPair(address _pair, bool _value) private {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[_pair] = _value;
        if (_value) {
            dividendTracker.excludeFromDividends(_pair);
        }
    }

    function setExternalMarket(
        address _address,
        bool _isExternalMarket
    ) external onlyOwner {
        externalMarkets[_address] = _isExternalMarket;
        if (_isExternalMarket) {
            isExcludeFromWalletLimit[_address] = _isExternalMarket;
        }
    }

    function setExcludeFromFee(
        address _address,
        bool _isExcludeFromFee
    ) external onlyOwner {
        isExcludeFromFee[_address] = _isExcludeFromFee;
    }

    function setExcludeFromDividends(
        address _address,
        bool _isExcludeFromDividends
    ) external onlyOwner {
        if (_isExcludeFromDividends) {
            dividendTracker.excludeFromDividends(_address);
        } else {
            dividendTracker.includeFromDividends(_address, balanceOf(_address));
        }
    }

    function setExcludeFromWalletLimit(
        address _address,
        bool _isExcludeFromWalletLimit
    ) external onlyOwner {
        isExcludeFromWalletLimit[_address] = _isExcludeFromWalletLimit;
    }

    function setWalletLimitPercentage(uint256 _percentage) external onlyOwner {
        walletLimitPercentage = _percentage;
    }

    function setTaxes(
        uint256 _autoLP,
        uint256 _devFee,
        uint256 _marketingFee
    ) external onlyOwner {
        autoLP = _autoLP;
        devFee = _devFee;
        marketingFee = _marketingFee;
    }

    function getTaxes()
        external
        view
        returns (uint256 s_autoLP, uint256 s_devFee, uint256 s_marketingFee)
    {
        return (autoLP, devFee, marketingFee);
    }

    function setMinContractTokensToSwap(uint256 _numToken) public onlyOwner {
        minContractTokensToSwap = _numToken;
    }

    function setMinRewardTokensToSwap(uint256 _numToken) public onlyOwner {
        minRewardTokensToSwap = _numToken;
    }

    function setSwapAll(bool _isWapAll) public onlyOwner {
        swapAll = _isWapAll;
    }

    function setRevokeSetBots() public onlyOwner {
        revokeSetBots = true;
    }

    function setBots(address[] calldata _bots, bool value) public onlyOwner {
        require(!revokeSetBots, "ERROR_REVOKED");
        for (uint256 i = 0; i < _bots.length; i++) {
            if (
                _bots[i] != uniswapV2Pair &&
                _bots[i] != address(uniswapV2Router)
            ) {
                isBot[_bots[i]] = value;
            }
        }
    }

    function setWalletAddress(
        address _devWallet,
        address _marketingWallet
    ) external onlyOwner {
        devWalletAddress = _devWallet;
        marketingWalletAddress = _marketingWallet;
    }

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        require(amountOut > 0, "ERROR_3");
        require(reserveIn > 0 && reserveOut > 0, "ERROR_4");
        amountIn = ((reserveIn * amountOut * 1000) /
            ((reserveOut - amountOut) * 997)).add(1);
    }

    function takeFees(
        uint256 curOrderId,
        address _from,
        address _to,
        uint256 _amount,
        uint256 externalPriceE18
    ) private returns (uint256) {
        uint256 remainingAmount;
        uint256 fees;
        uint256 baseFees;
        uint256 floorFees;
        uint256 rewardTokens;
        uint256 currentPriceE18;
        uint256 midPriceE18;
        uint256 totEthOut;
        uint256 spentEth;
        uint256 reservesEth;
        uint256 reservesTard;
        if (automatedMarketMakerPairs[_from] || (externalPriceE18 != 0)) {
            (reservesTard, reservesEth) = incentivesTracker.getReserves();
            uint256 startingPriceE18 = (reservesEth * (10 ** 18)) /
                reservesTard;
            spentEth = getAmountIn(_amount, reservesEth, reservesTard);
            emit ExpectedSpentEth(spentEth, _amount, reservesEth, reservesTard);
            uint256 startingMidPriceE18 = (spentEth * (10 ** 18)) / _amount;
            (
                remainingAmount,
                baseFees,
                floorFees,
                currentPriceE18,
                midPriceE18
            ) = incentivesTracker.gotBuy(
                curOrderId,
                _from,
                _to,
                _amount,
                externalPriceE18,
                block.timestamp,
                reservesTard,
                reservesEth,
                spentEth
            );
            emit GotBuy(
                externalPriceE18,
                _amount,
                reservesEth,
                reservesTard,
                remainingAmount,
                baseFees,
                floorFees,
                spentEth,
                currentPriceE18,
                midPriceE18,
                startingPriceE18,
                startingMidPriceE18
            );
            require(
                _amount == remainingAmount + baseFees + floorFees,
                "BUY_ERROR_1"
            );
            fees = baseFees + floorFees;
            super._transfer(_from, address(this), fees);
            emit BuyFees(
                _from,
                address(this),
                remainingAmount,
                baseFees,
                floorFees
            );
        } else {
            uint256 senderBalance = balanceOf(_from);
            uint256 gotUserBuysTot = incentivesTracker.userBuysTot(_from);
            emit BeforeSellStats(_amount, gotUserBuysTot, senderBalance);
            (
                remainingAmount,
                fees,
                rewardTokens,
                totEthOut,
                midPriceE18
            ) = incentivesTracker.gotSell(
                curOrderId,
                _from,
                _to,
                _amount,
                initialBuyTimestamp[_from],
                senderBalance
            );
            emit GotSell(
                _amount,
                remainingAmount,
                fees,
                rewardTokens,
                totEthOut,
                midPriceE18
            );
            pendingTokensForReward = pendingTokensForReward.add(rewardTokens);
            super._transfer(_from, address(this), fees);
            uint256 tokensToSwap = balanceOf(address(this)).sub(
                pendingTokensForReward
            );
            if (tokensToSwap > minContractTokensToSwap) {
                if (!swapAll) {
                    tokensToSwap = minContractTokensToSwap;
                }
                distributeTokensEth(tokensToSwap);
            }
            if (pendingTokensForReward > minRewardTokensToSwap) {
                swapAndSendDividends(pendingTokensForReward);
            }
            emit SellFees(_from, address(this), remainingAmount, fees);
        }
        return remainingAmount;
    }

    function distributeTokensEth(uint256 _tokenAmount) private {
        uint256 tokensForLiquidity = _tokenAmount.mul(autoLP).div(100);
        uint256 halfLiquidity = tokensForLiquidity.div(2);
        uint256 tokensForSwap = _tokenAmount.sub(halfLiquidity);
        uint256 totalEth = swapTokensForEth(tokensForSwap);
        uint256 ethForAddLP = totalEth.mul(autoLP).div(100);
        uint256 devFeesToSend = totalEth.mul(devFee).div(100);
        uint256 marketingFeesToSend = totalEth.mul(marketingFee).div(100);
        uint256 remainingEthForFees = totalEth
            .sub(ethForAddLP)
            .sub(devFeesToSend)
            .sub(marketingFeesToSend);
        devFeesToSend = devFeesToSend.add(remainingEthForFees);
        sendEthToWallets(devFeesToSend, marketingFeesToSend);
        if (halfLiquidity > 0 && ethForAddLP > 0) {
            addLiquidity(halfLiquidity, ethForAddLP);
        }
    }

    function sendEthToWallets(
        uint256 _devFees,
        uint256 _marketingFees
    ) private {
        if (_devFees > 0) {
            payable(devWalletAddress).transfer(_devFees);
        }
        if (_marketingFees > 0) {
            payable(marketingWalletAddress).transfer(_marketingFees);
        }
        emit DistributeFees(_devFees, _marketingFees);
    }

    function swapTokensForEth(uint256 _tokenAmount) private returns (uint256) {
        uint256 initialEthBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH_ADDRESS;
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 receivedEth = address(this).balance.sub(initialEthBalance);
        emit SwapTokensForEth(_tokenAmount, receivedEth);
        return receivedEth;
    }

    function swapEthForTokens(
        uint256 _ethAmount,
        address _to
    ) private returns (uint256) {
        uint256 initialTokenBalance = balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = address(this);
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _ethAmount
        }(0, path, _to, block.timestamp);
        uint256 receivedTokens = balanceOf(address(this)).sub(
            initialTokenBalance
        );
        emit SwapEthForTokens(_ethAmount, receivedTokens);
        return receivedTokens;
    }

    function addLiquidity(uint256 _tokenAmount, uint256 _ethAmount) private {
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
        uniswapV2Router.addLiquidityETH{value: _ethAmount}(
            address(this),
            _tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        emit AddLiquidity(_tokenAmount, _ethAmount);
    }

    function swapAndSendDividends(uint256 _tokenAmount) private {
        uint256 dividends = swapTokensForEth(_tokenAmount);
        pendingTokensForReward = pendingTokensForReward.sub(_tokenAmount);
        uint256 totalEthToSend = dividends.add(pendingEthReward);
        (bool success, ) = address(dividendTracker).call{value: totalEthToSend}(
            ""
        );
        if (success) {
            emit SendDividends(dividends);
        } else {
            pendingEthReward = pendingEthReward.add(dividends);
        }
    }

    function availableContractTokenBalance() public view returns (uint256) {
        return balanceOf(address(this)).sub(pendingTokensForReward);
    }

    function getHistory(
        address _account,
        uint256 _limit,
        uint256 _pageNumber
    ) external view returns (ClaimedEth[] memory) {
        require(_limit > 0 && _pageNumber > 0, "Invalid arguments");
        uint256 userClaimedCount = userClaimedIds[_account].length;
        uint256 end = _pageNumber * _limit;
        uint256 start = end - _limit;
        require(start < userClaimedCount, "Out of range");
        uint256 limit = _limit;
        if (end > userClaimedCount) {
            end = userClaimedCount;
            limit = userClaimedCount % _limit;
        }
        ClaimedEth[] memory myClaimedEth = new ClaimedEth[](limit);
        uint256 currentIndex = 0;
        for (uint256 i = start; i < end; i++) {
            uint256 hId = userClaimedIds[_account][i];
            myClaimedEth[currentIndex] = claimedEthMap[hId];
            currentIndex += 1;
        }
        return myClaimedEth;
    }

    function getHistoryCount(address _account) external view returns (uint256) {
        return userClaimedIds[_account].length;
    }

    function emergencyWithdrawDivs() external onlyOwner {
        dividendTracker.emergencyWithdraw(owner());
    }

    receive() external payable {}
}
