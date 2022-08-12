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
    uint256 constant internal BET_AMOUNT = 5 * 10 ** 15; // 10 ** 15 = 0.001 wei

    uint256 private _pot; // 팟 머니를 저장하는 곳

    // 2. Lottery Queue 설계
    uint256 private _tail;
    uint256 private _head;
    mapping (uint256 => BetInfo) private _bets; // 사람들이 베팅한 정보들을 queue 자료 형으로 저장

    constructor() public {
        owner = msg.sender;
    }

    function getSomeValue() public pure returns (uint256 value) {
        return 5;
    }

    function getPot() public view returns (uint256 pot) {
        return _pot;
    }

    // Bet
        // save the bet to the queue
    // Distribute
        // check the answer
    
    function getBetInfo(uint256 index) public view returns (uint256 answerBlockNumber, address bettor, byte challenges) {
        BetInfo memory b = _bets[index];
        answerBlockNumber = b.answerBlockNumber;
        bettor = b.bettor;
        challenges = b.challenges;
    }

    function pushBet(byte challenges) public returns (bool) {
        BetInfo memory b;
        b.bettor = msg.sender;
        b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL;
        b.challenges = challenges;

        _bets[_tail] = b;
        _tail++;

        return true;
    }

    function popBet(uint256 index) public returns (bool) {
        delete _bets[index]; // queue라는 자료에서 데이터를 삭제한다는 개념 보다 초기화를 하겠다는 개념, delete를 통해 일정량의 gas를 돌려 받는다
        return true;
    }
}