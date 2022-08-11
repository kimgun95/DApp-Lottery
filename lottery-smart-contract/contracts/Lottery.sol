pragma solidity >=0.4.22 <0.9.0; // 스마트 컨트랙트 버전

contract Lottery {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function getSomeValue() public pure returns (uint256 value) {
        return 5;
    }

}