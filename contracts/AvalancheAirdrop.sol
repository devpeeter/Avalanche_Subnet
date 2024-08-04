// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IERC20 {
    
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function mint(address user, uint256 amount) external;

    function approve(address spender, uint256 value) external returns (bool);
}

contract AvalancheAirdrop {

    IERC20 public  token;
    address owner;

    event AirdropClaimed( address indexed  user, uint256 amount);
    
    struct Elligible {
        address user;
        uint amount;
        bool claimed;
    }

    mapping(address => Elligible) public elligibleUsers;

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
        token.mint(address(this), 1000000);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    function addAirdropees(address[] calldata _airdropeeAddress) external onlyOwner {

        for (uint256 i = 0; i < _airdropeeAddress.length; i++) {

            address _user = _airdropeeAddress[i];

            if (_user == address(0) || elligibleUsers[_user].user != address(0))
                continue;

            uint256 amount = 1000;

            require(token.approve(_user, amount), "Approval failed!");
 
            elligibleUsers[_user] = Elligible(_user, amount, false);   
        }
    }

    function claimAirdrop() external {

        Elligible storage elligible = elligibleUsers[msg.sender];

        require(elligible.user != address(0), "You are not elligible");
        
        require(elligible.claimed == false, "You have claimed");

        elligible.claimed = true;

        require(token.transferFrom(address(this), elligible.user, elligible.amount), "Airdrop failed!");

        emit AirdropClaimed(elligible.user, elligible.amount);
    }
}
