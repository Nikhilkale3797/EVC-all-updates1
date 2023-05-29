// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract vesting {
    IERC20 token;


    mapping(address => uint256) public current_balance_vested;
    mapping(address => uint256) account_expiry;
    mapping(address => bool) public is_locked;
    address owner;
    uint vestTime;
    //uint256 public expire_time = account_expiry[msg.sender];

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyowner() {
        
       require(msg.sender == owner,"you should be owner");
         _;
      }

    function lock(
        //address _from,
        uint256 _amount,
        uint256 _expiry
    ) external {
        token.transferFrom(msg.sender, address(this), _amount);

        current_balance_vested[msg.sender] += _amount;
        account_expiry[msg.sender] = _expiry;
        is_locked[msg.sender] = true;
    }

    function withdraw() external {
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require(
            block.timestamp > account_expiry[msg.sender],
            "token have allready transfered"
        );

        uint256 percentagewithdraw = current_balance_vested[msg.sender];
        uint256 transferammount = percentagewithdraw / 10;
        token.transfer(msg.sender, transferammount);

        current_balance_vested[msg.sender] -= transferammount;
        account_expiry[msg.sender] = block.timestamp + 60;
    }

    function emengercy_withdraw() external {
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require (current_balance_vested[msg.sender]>0,"no balance in your account");
        uint256 transferammount = current_balance_vested[msg.sender];
        
        token.transfer(msg.sender, transferammount);
        current_balance_vested[msg.sender]=0;

        
    }

function setVestTime(uint _vestTime) public onlyowner{
    vestTime = _vestTime;
}


    function getTime() external view returns (uint256) {
        return block.timestamp;
    }


    function expiryTime() external view returns (uint256) {
        return account_expiry[msg.sender];
        }
}
