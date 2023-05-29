// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract vesting{

    IERC20 token;
    address public reciever;
    uint public  amount;
    uint public expiry;
    //bool public locked = false;
    bool public clamed = false;

    //mapping (address=>uint) account_balance;
    mapping (address=>uint) public current_balance_vested;
    mapping (address=>uint) public account_expiry;
    mapping (address => bool) public is_locked;


    // struct account_info {
    //     uint expiry;
    //     address account;
    //     uint ammount;
    //     mapping (address=>uint) account_balance;

    //     }


    constructor(address _token) {
        token = IERC20(_token);
    }

    function lock (address _from,uint _amount,uint _expiry) external {
        token.transferFrom(_from,address(this),_amount);
        //reciever = _reciever;
        // amount = amount + _amount;
        current_balance_vested[_from] += _amount;
        account_expiry[_from] = _expiry;
        is_locked[_from] = true;
    }

    function withdraw() external {
        //require (block.timestamp >  expiry , "token have allready transfered");
        //require(!clamed,"token have already claimed");
        //clamed  = true;
        require(is_locked[msg.sender]== true,"you have not vseted token");
        require (block.timestamp >  account_expiry[msg.sender] , "token have allready transfered");

        //uint percentagewithdraw = amount /10;
        // token.transfer(reciever,percentagewithdraw);

        uint percentagewithdraw = current_balance_vested[msg.sender];
        uint transferammount= percentagewithdraw / 10; 
        token.transfer(msg.sender,transferammount);
        //amount = amount - percentagewithdraw;

        current_balance_vested[msg.sender] -= transferammount;
        account_expiry[msg.sender] = block.timestamp + 60;
    }

    function getTime() external view returns(uint){
        return block.timestamp;
    }
    
}
