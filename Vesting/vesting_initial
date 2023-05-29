// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract vesting is Ownable{
    IERC20 token;

address vester = msg.sender;
uint vestTime = 60;

    mapping(address => uint256) public current_balance_vested;
    mapping(address => uint256) account_expiry;
    mapping(address => bool) public is_locked;
    //uint256 public expire_time = account_expiry[msg.sender];

    constructor(address _token) {
        token = IERC20(_token);
    }

    function lock(
        
        uint256 _amount,
        uint256 _expiry
    ) external {
        token.transferFrom(vester, address(this), _amount);

        current_balance_vested[vester] += _amount;
        account_expiry[vester] = _expiry;
        is_locked[vester] = true;
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
        account_expiry[msg.sender] = block.timestamp + vestTime;
    }

    function emengercy_withdraw() external {
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require (current_balance_vested[msg.sender]>0,"no balance in your account");
        uint256 transferammount = current_balance_vested[msg.sender];
        
        token.transfer(msg.sender, transferammount);
        current_balance_vested[msg.sender]=0;

        
    }

function setVestTime(uint _vestTime) public onlyOwner{
    vestTime = _vestTime;
}


    function getTime() external view returns (uint256) {
        return block.timestamp;
    }


    function expiryTime() external view returns (uint256) {
        return account_expiry[msg.sender];
        }
}
