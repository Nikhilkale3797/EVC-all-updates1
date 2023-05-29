// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract vesting {
    IERC20 token;


    mapping(address => uint256) public current_balance_vested;
    mapping(address => uint256) account_expiry;
    mapping(address => bool) public is_locked;
    mapping(address=>id_info[]) public account_id_array;
    //mapping(uint => uint) public id_withdraw;
    //mapping(uint => uint) public id_expiry;
    struct id_info{
        uint amount;
        uint id_expiry;
        uint emergency_expiry;
    }

    //id_amount[] public idinformation;

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

    // function lock(
    //     //address _from,
    //     uint256 _amount,
    //     uint256 _expiry
    // ) external {
    //     token.transferFrom(msg.sender, address(this), _amount);

    //     current_balance_vested[msg.sender] += _amount;
    //     account_expiry[msg.sender] = _expiry;
    //     is_locked[msg.sender] = true;
    // }

    function lock(
        //address _from,
        uint256 _amount
       
    ) public {
        token.transferFrom(msg.sender, address(this), _amount);
        //current_balance_vested[msg.sender] += _amount;

        id_info memory new_entry = id_info(_amount,block.timestamp,block.timestamp+180);
        account_id_array[msg.sender].push(new_entry);

        is_locked[msg.sender] = true;
    }


    function withdraw(uint _index) public {
        id_info[] storage structarray = account_id_array[msg.sender];
        id_info storage structelement = structarray[_index];
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require(
            block.timestamp > structelement.id_expiry,
            "token have allready transfered"
        );
        require(structelement.amount > 0,"no balance in your account");

        uint256 percentagewithdraw = structelement.amount;
        uint256 transferammount = percentagewithdraw / 10;
        token.transfer(msg.sender, transferammount);

       // current_balance_vested[msg.sender] -= transferammount;
        structelement.amount = structelement.amount - transferammount;
        structelement.id_expiry = block.timestamp + 60;
    }

    function emengercy_withdraw(uint _index) public {
        id_info[] storage structarray = account_id_array[msg.sender];
        id_info storage structelement = structarray[_index];
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require(block.timestamp > structelement.emergency_expiry);
        require (structelement.amount>0,"no balance in your account");
        uint256 transferammount = structelement.amount;
        
        token.transfer(msg.sender, transferammount);
        //current_balance_vested[msg.sender] -= transferammount;
        structelement.amount = 0;

        
    }

function setVestTime(uint _vestTime) public onlyowner{
    vestTime = _vestTime;
}


    function getTime() external view returns (uint256) {
        return block.timestamp;
    }


    function expiryTime(uint _index) public view returns (uint256) {
        id_info[] memory structarray = account_id_array[msg.sender];
        id_info memory structelement = structarray[_index];
        return structelement.id_expiry;
        }
}
