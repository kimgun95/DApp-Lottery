pragma solidity >=0.4.22 <0.9.0; // 스마트 컨트랙트 버전

contract Lottery {

    // 1. Lottery 도메인 설계
    struct BetInfo {
        uint256 answerBlockNumber; // 사용자가 맞추려는 정답 블록
        address payable bettor; // 특정 주소에 돈을 보내려면 payable 필요, 배팅 참여자
        byte challenges; // 0xab, 정답
    }

    address public owner;

    uint256 constant internal BLOCK_LIMIT = 256; // 블록 해시는 256번 째 전 까지만 확인할 수 있음
    uint256 constant internal BET_BLOCK_INTERVAL = 3;
    uint256 constant internal BET_AMOUNT = 5 * 10 ** 15; // 10 ** 15wei = 0.001 ETH

    uint256 private _pot; // 팟 머니를 저장하는 곳

    enum BlockStatus {Checkable, NotRevealed, BlockLimitPassed}

    // 2. Lottery Queue 설계
    uint256 private _tail;
    uint256 private _head;
    mapping (uint256 => BetInfo) private _bets; // 사람들이 베팅한 정보들을 queue 자료 형으로 저장

    // Event 작성
    event BET(uint256 index, address bettor, uint256 amount, byte challenges, uint256 answerBlockNumber);

    constructor() public {
        owner = msg.sender;
    }

    function getSomeValue() public pure returns (uint256 value) {
        return 5;
    }

    function getPot() public view returns (uint256 pot) {
        return _pot;
    }

    /**
    * @dev 베팅을 한다. 유저는 0.005 ETH를 보내야 하고, 베팅용 1 byte 글자를 함께 보낸다.
    * 큐에 저장된 베팅 정보는 이후 distribute 함수에서 해결된다.
    * @param challenges 유저가 베팅하는 글자
    * @return 함수가 잘 수행되었는지 확인하는 bool 값
     */
     function bet(byte challenges) public payable returns (bool result) {
        // Check the proper ether is sent
        require(msg.value == BET_AMOUNT, "Not enough ETH");

        // Push bet to the queue
        require(pushBet(challenges), "Fail to add a new Bet Info");

        // emit event
        emit BET(_tail - 1, msg.sender, msg.value, challenges, block.number + BET_BLOCK_INTERVAL);

        return true;
     }

    // Distribute
    function distribute() public {
        // head 3 4 5 6 7 8 9 10 11 12 tail
        
        uint256 cur;
        BetInfo memory b;
        BlockStatus curBlockStatus;
        for (cur=_head; cur<_tail; cur++) {
            b = _bets[cur];
            curBlockStatus = getBlockStatus(b.answerBlockNumber);
            
            if (curBlockStatus == BlockStatus.Checkable) { // Checkable : AnswerBlockNumber(나의 정답 블록) < block.number(현재 블록) < BLOCK_LIMIT + AnswerBlockNumber
                // if win, bettor gets pot

                // if fail, bettor's money goes pot

                // if draw, refund bettor's money

            } else if (curBlockStatus == BlockStatus.NotRevealed) { // Not Revealed : block.number <= AnswerBlockNumber
                break;
            } else if (curBlockStatus == BlockStatus.BlockLimitPassed) { // Block Limit Passed : block.number >= AnswerBlock + BLOCK_LIMIT
                // refund
                // emit refund
            }
            
            // check the answer
        }
    }

    function getBlockStatus(uint256 answerBlockNumber) internal view returns (BlockStatus) {
        if (block.number > answerBlockNumber && block.number < BLOCK_LIMIT + answerBlockNumber) {
            return BlockStatus.Checkable;
        } else if (block.number <= answerBlockNumber) {
            return BlockStatus.NotRevealed;
        } else if (block.number >= answerBlockNumber + BLOCK_LIMIT) {
            return BlockStatus.BlockLimitPassed;
        }
        return BlockStatus.BlockLimitPassed; // 디폴트로 반환이 될 수 있을 것을 리턴
    }

        // check the answer
    
    function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, byte challenges) {
        BetInfo memory b = _bets[index];
        answerBlockNumber = b.answerBlockNumber;
        bettor = b.bettor;
        challenges = b.challenges;
    }

    function pushBet(byte challenges) public returns (bool) {
        BetInfo memory b;
        b.bettor = msg.sender; // 20 byte
        b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL; // 32 byte == 20000 gas
        b.challenges = challenges; // byte (bettor + challenges == 20000 gas)

        _bets[_tail] = b; // mapping만 해주면 됨 (gas 발생 x)
        _tail++; // 32 byte == 20000 gas

        return true;
    }

    function popBet(uint256 index) public returns (bool) {
        delete _bets[index]; // queue라는 자료에서 데이터를 삭제한다는 개념 보다 초기화를 하겠다는 개념, delete를 통해 일정량의 gas를 돌려 받는다
        return true;
    }
}