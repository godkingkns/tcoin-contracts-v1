const UniswapV2RouterAddress = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'
const WETH_ADDRESS = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
const USDT_ADDRESS = '0xdAC17F958D2ee523a2206206994597C13D831ec7'
const UniswapV2PairWETHUSDTAddress = '0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852'
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000369'

const BuyFeeFloorPricePerTokenE18 = 1
const TotalSupply = BigInt(1e12 * 1e9)
const TokenName = 'Test'
const TokenSymbol = 'TEST'

const MinimumTokenBalanceForDividends = BigInt(10000 * 10 ** 9)

module.exports = { 
    UniswapV2RouterAddress, 
    WETH_ADDRESS, 
    USDT_ADDRESS,
    ZERO_ADDRESS, 
    BuyFeeFloorPricePerTokenE18, 
    UniswapV2PairWETHUSDTAddress, 
    TotalSupply, TokenName, TokenSymbol,
    MinimumTokenBalanceForDividends
}