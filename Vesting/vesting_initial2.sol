// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract vesting {
    IERC20 token;

    mapping(address => uint256) public current_balance_vested;
    mapping(address => uint256) account_expiry;
    mapping(address => bool) public is_locked;
    mapping(address => uint256) public cliff_amount;
    mapping(address => uint256) public cliff_account_expiry;
    mapping(address => bool) public cliff_locked;
    mapping(address => uint256) public startDuration;
    mapping(address => uint256) public installment_list;
    address owner;
    uint256 vestTime;
    uint256 public installment;

    bool public revocable;

    //uint256 public expire_time = account_expiry[msg.sender];

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner, "you should be owner");
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
        startDuration[msg.sender] = block.timestamp;
        //installment = withdraw_amount_installment();
        installment_list[msg.sender] = withdraw_amount_installment();
    }

    // function withdraw() external {
    //     require(is_locked[msg.sender] == true, "you have not vseted token");
    //     require(
    //         block.timestamp > account_expiry[msg.sender],
    //         "token have allready transfered"
    //     );

    //     uint256 percentagewithdraw = current_balance_vested[msg.sender];
    //     uint256 transferammount = percentagewithdraw / 10;
    //     token.transfer(msg.sender, transferammount);

    //     current_balance_vested[msg.sender] -= transferammount;
    //     account_expiry[msg.sender] = block.timestamp + 60;
    // }

    function withdraw_amount_installment() internal view returns (uint256) {
        uint256 transferammount = current_balance_vested[msg.sender] / 4;
        return transferammount;
    }

    function installationwithdraw() external {
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require(
            block.timestamp > account_expiry[msg.sender],
            "token have allready transfered"
        );

        // uint256 installwithdraw = current_balance_vested[msg.sender];
        uint256 transferammount = installment_list[msg.sender];
        token.transfer(msg.sender, transferammount);

        current_balance_vested[msg.sender] -= transferammount;
        account_expiry[msg.sender] = block.timestamp + 60;
    }

    function emengercy_withdraw() external {
        require(
            block.timestamp > startDuration[msg.sender] + 180,
            "minimum vesting period not reached"
        );
        require(is_locked[msg.sender] == true, "you have not vseted token");
       
        
        uint256 transferammount = current_balance_vested[msg.sender] + cliff_amount[msg.sender];

        token.transfer(msg.sender, transferammount);
        current_balance_vested[msg.sender] = 0;
        cliff_amount[msg.sender] = 0;
    }

    function revokeTokens() external {
        require(revocable == true, "fund not revokable");
        require(is_locked[msg.sender] == true, "you have not vseted token");
        require(
            current_balance_vested[msg.sender] > 0,
            "no balance in your account"
        );
        uint256 transferammount = current_balance_vested[msg.sender] +
            cliff_amount[msg.sender];

        token.transfer(msg.sender, transferammount);
        current_balance_vested[msg.sender] = 0;
        cliff_amount[msg.sender] = 0;
    }

    function lock_cliff(uint256 _amount, uint256 _cliff_period) external {
        token.transferFrom(msg.sender, address(this), _amount);

        cliff_amount[msg.sender] += _amount;
        cliff_account_expiry[msg.sender] = block.timestamp + _cliff_period;
        cliff_locked[msg.sender] = true;
    }

    function withdraw_cliff() external {
        require(cliff_locked[msg.sender] == true, "you have not cliffed token");
         require(cliff_account_expiry[msg.sender] < block.timestamp, "maturity of token not reached");
        require(
            cliff_amount[msg.sender] > 0,
            "no cliff balance in your account"
        );
        uint256 transferammount = cliff_amount[msg.sender];

        token.transfer(msg.sender, transferammount);
        cliff_amount[msg.sender] = 0;
    }

    function setVestTime(uint256 _vestTime) public onlyowner {
        vestTime = _vestTime;
    }

    function getTime() external view returns (uint256) {
        return block.timestamp;
    }

    function expiryTime() external view returns (uint256) {
        return account_expiry[msg.sender];
    }

    function set_revocable(bool _permision) public onlyowner {
        revocable = _permision;
    }
}
