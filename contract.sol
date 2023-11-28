// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TestCode {

    AggregatorV3Interface internal priceFeed;

    constructor() payable {
        owner = msg.sender;
    }

    struct User {
        address payable userAddr;
        uint userId;
        uint numberTries;
        uint sequenceGuessed;
        uint unlocked;
        string userName;
    }

    User[] users;

    mapping (address => bool[2]) userNumSequence;
    mapping (address => uint) user;
    mapping (address => bool) registration;
    mapping (address => uint) public winnersPrize;

    address[] public winnersList;

    address public owner;

    uint public totalNumberUsers;
    uint public totalNumberTries;
    uint public totalNumberGuessed;
    uint public tempNumberTriesLock;

    function getUsers(uint _index) external view returns (
        uint, 
        string memory, 
        uint, 
        uint, 
        uint ) {

        User storage _user = users[_index];
        return (
            _user.userId, 
            _user.userName, 
            _user.numberTries, 
            _user.sequenceGuessed, 
            _user.unlocked
        );
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function setUser(string memory _userName) public {
        users.push(User(payable(msg.sender), totalNumberUsers + 1, 0, 0, 0, _userName));
        user[msg.sender] = totalNumberUsers;
        totalNumberUsers ++;
        registration[msg.sender] = true;
    }

    function getMyUser() external view returns (
        address,    
        uint256, 
        string memory, 
        uint256, 
        uint256, 
        uint256 ) {

        uint _userKey = user[msg.sender];
        User storage _user = users[_userKey];
        return (
            _user.userAddr,
            _user.userId, 
            _user.userName, 
            _user.numberTries, 
            _user.sequenceGuessed, 
            _user.unlocked
        );
    }

    function updateName(string calldata _name) external {
        uint _userKey = user[msg.sender];
        User storage _user = users[_userKey];
        _user.userName = _name;
    }

    function guessTheNumber1(uint _number) guessMod(_number) payable external {
        require(userNumSequence[msg.sender][0] == false,
        "Error: number guessed");

        uint lockNumber = uint(keccak256(abi.encodePacked
        (block.timestamp, totalNumberTries))) % 10;

        if (lockNumber == _number) {
            userNumSequence[msg.sender][0] = true; 
            totalNumberGuessed ++;

            uint _userKey = user[msg.sender];
            User storage _user = users[_userKey]; 
            _user.sequenceGuessed ++;
        }
    }

        function guessTheNumber2(uint _number) guessMod(_number) payable public {
        require(userNumSequence[msg.sender][0] == true &&
        userNumSequence[msg.sender][1] == false,
        "Error: try another sequence number");

        uint lockNumber = uint(keccak256(abi.encodePacked
        (block.timestamp, totalNumberTries))) % 10;

        if (lockNumber == _number) {
            uint _userKey = user[msg.sender];
            User storage _user = users[_userKey]; 
            _user.sequenceGuessed ++;

            userNumSequence[msg.sender][1] = true;
            totalNumberGuessed ++;
        }
    }

    function guessTheNumber3(uint _number) guessMod(_number) payable external {
        require(userNumSequence[msg.sender][0] == true &&
        userNumSequence[msg.sender][1] == true, 
        "Error: previews numbers must be guessed");

        uint lockNumber = uint(keccak256(abi.encodePacked
        (block.timestamp, totalNumberTries))) % 10;

        if (lockNumber == _number) {
            winnersList.push(msg.sender);
            winnersPrize[msg.sender] = address(this).balance * 7/10;

            (payable(msg.sender)).transfer(address(this).balance * 7/10);
            (payable(owner)).transfer(address(this).balance);

            userNumSequence[msg.sender][0] = false;
            userNumSequence[msg.sender][1] = false;
            tempNumberTriesLock = 0;

            uint _userKey = user[msg.sender];
            User storage _user = users[_userKey]; 
            _user.unlocked ++;           
            _user.sequenceGuessed ++;
            totalNumberGuessed ++;
        }
    }

    modifier guessMod(uint _number) {
        require(registration[msg.sender] == true, "register first");

        int ethUsdPrice = getLatestEthUsdPrice();
        uint requiredWei = 10 * 1e18 / uint(ethUsdPrice);
        require(msg.value == requiredWei, "Amount must equal 10 USD");

        uint _userKey = user[msg.sender];
        User storage _user = users[_userKey];
        _user.numberTries++;
        totalNumberTries++;
        tempNumberTriesLock++;

        _;
    }

    function getLatestEthUsdPrice() public pure returns (int) {
        // Return a constant value for testing purposes
        return 200000000;
    }
    
    receive() external payable {}

}
