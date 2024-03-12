const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require('chai')

const constants = require('../constants')

describe("Tcoin", function () {
    describe("Deployment", function () {
        let tCoinContract = null;
        let incentivesContract = null;
        let incentivesTracker = null;

        let dividendContract = null;
        let dividendTracker = null;

        let devWalletAddress = null;
        let marketingWalletAddress = null;
        let ownerAddress = null;
        let bobAddress, aliceAddress = null;
        
        beforeEach(async function () {
            const [_ownerAddress, _devWalletAddress, _marketingWalletAddress, _bobAddress, _aliceAddress ] = await ethers.getSigners();
            const TcoinFactory = await ethers.getContractFactory("Tcoin");

            ownerAddress = _ownerAddress;
            devWalletAddress = _devWalletAddress;
            marketingWalletAddress = _marketingWalletAddress;
            bobAddress = _bobAddress;
            aliceAddress = _aliceAddress;

            tCoinContract = await TcoinFactory.deploy(constants.USDT_ADDRESS, constants.UniswapV2RouterAddress, devWalletAddress, marketingWalletAddress, constants.BuyFeeFloorPricePerTokenE18, { from: ownerAddress });
            incentivesTracker = await tCoinContract.incentivesTracker();
            incentivesContract = await ethers.getContractAt('TardIncentivesTracker', incentivesTracker);

            dividendTracker = await tCoinContract.dividendTracker();
            dividendContract = await ethers.getContractAt('TardDividendTracker', dividendTracker);
        })

        it('Should set deployment variables correctly', async function () {
            expect(await tCoinContract.name()).to.equal(constants.TokenName);
            expect(await tCoinContract.symbol()).to.equal(constants.TokenSymbol);

            expect(await tCoinContract.WETH_ADDRESS()).to.equal(constants.WETH_ADDRESS);
            expect(await tCoinContract.uniswapV2PairUsdtAddress()).to.equal(constants.UniswapV2PairWETHUSDTAddress);
            const ownerBalance = await tCoinContract.balanceOf(ownerAddress);
            expect(ownerBalance.toString()).to.equal(constants.TotalSupply.toString());

            expect(await tCoinContract.isExcludeFromFee(tCoinContract)).to.equal(true);
            expect(await tCoinContract.isExcludeFromFee(ownerAddress)).to.equal(true);
            expect(await tCoinContract.isExcludeFromFee(bobAddress)).to.equal(false);

            expect(await tCoinContract.isExcludeFromWalletLimit(ownerAddress)).to.equal(true);
            expect(await tCoinContract.isExcludeFromWalletLimit(tCoinContract)).to.equal(true);
            expect(await tCoinContract.isExcludeFromWalletLimit(constants.UniswapV2RouterAddress)).to.equal(true);
            expect (await tCoinContract.isExcludeFromWalletLimit(bobAddress)).to.equal(false);         
        })

        describe("TardIncentivesTracker Deployment", function () {
            it('Should set deployments variables correctly', async function () {
                expect(await incentivesContract.otherOwner()).to.equal(ownerAddress);
                expect(await incentivesContract.TARD_ADDRESS()).to.equal(tCoinContract);
                expect(await incentivesContract.usdtMode()).to.equal(true);
                expect(await incentivesContract.uniswapV2PairUsdt()).to.equal(constants.UniswapV2PairWETHUSDTAddress);
                const minutesRangeTaxes = await incentivesContract.minutesRangeTaxes(1);
                expect(minutesRangeTaxes.from.toString()).to.equal(`0`);
                expect(minutesRangeTaxes.to.toString()).to.equal(`${43200 * 60}`);
                expect(minutesRangeTaxes.tax.toString()).to.equal(`30`);
                expect(minutesRangeTaxes.preScaling.toString()).to.equal(`100`);
                expect(minutesRangeTaxes.postScaling.toString()).to.equal(`100`);
                expect(await incentivesContract.dynamicFloorFrac()).to.equal(100);
                expect(await incentivesContract.antiFlashloanMode()).to.equal(true);
                expect(await incentivesContract.maxIndexMinutesRange()).to.equal(1);
                expect(await incentivesContract.buyFeeFloorPricePerTokenE18()).to.equal(constants.BuyFeeFloorPricePerTokenE18);
                expect(await incentivesContract.sellCapFloorPricePerTokenE18()).to.equal(0);
                expect(await incentivesContract.refundPeriod()).to.equal(15 * 60);
            })
        })

        describe("TardDividendTracker Deployment", function () {
            it('Should set deployments variables correctly', async function () {
                expect(await dividendContract.minimumTokenBalanceForDividends()).to.equal(constants.MinimumTokenBalanceForDividends);
                expect(await dividendContract.excludedFromDividends(dividendTracker)).to.equal(true);
                expect(await dividendContract.excludedFromDividends(tCoinContract)).to.equal(true);
                expect(await dividendContract.excludedFromDividends(ownerAddress)).to.equal(true);
                expect(await dividendContract.excludedFromDividends(constants.UniswapV2RouterAddress)).to.equal(true);
                expect(await dividendContract.excludedFromDividends(constants.ZERO_ADDRESS)).to.equal(true);
            })
        })
    })
})