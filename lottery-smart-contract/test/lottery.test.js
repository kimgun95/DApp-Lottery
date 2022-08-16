const Lottery = artifacts.require("Lottery");
const assertRevert = require('./assertRevert');
const expectEvent = require('./expectEvent');

contract('Lottery', function([deployer, user1, user2]){
    let lottery;
    let betAmount = 5 * 10 ** 15;
    let betBlockInterval = 3;

    beforeEach(async () => {
        lottery = await Lottery.new();
    })

    it('getPot should return current pot', async () => {
        let pot = await lottery.getPot();
        assert.equal(pot, 0);
    })

    describe.only('Bet', function () {
        it('should fail when the bet money is not 0.005 ETH', async () => {
            // Fail transaction
            await assertRevert(lottery.bet('0xab', {from: user1, value: 4000000000000000}));
            // transaction object {chainId, value, to, from, gas(Limit), gasPrice}
        })

        it('should put the bet to the queue with 1 bet', async () => {
            //bet
            let receipt = await lottery.bet('0xab', {from: user1, value: betAmount});
            // console.log(receipt);

            let pot = await lottery.getPot();
            assert.equal(pot, 0);

            //check contract balance == 0.005 ETH
            let contractBalance = await web3.eth.getBalance(lottery.address);
            // assert(user1 != lottery.address); // 궁금해서 user1 과 lottery.address를 비교해봤다. 둘은 같지 않다.
            assert.equal(contractBalance, betAmount);
            
            // check bet info
            let currentBlockNumber = await web3.eth.getBlockNumber();
            let bet = await lottery.getBetInfo(0);

            assert.equal(bet.answerBlockNumber, currentBlockNumber + betBlockInterval);
            assert.equal(bet.bettor, user1);
            assert.equal(bet.challenges, '0xab');

            // check log
            await expectEvent.inLogs(receipt.logs, 'BET');
        })
    })

});