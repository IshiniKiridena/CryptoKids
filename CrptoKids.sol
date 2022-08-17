//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract CryptoKids {
    //Owner - DAD
    address owner; //address is a datatype

    //this will fire when kid receives his money
    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);

    //---constructor will be called only when the contract is deployed
    //whoever deployes this is the owner
    constructor(){
        //dad is the owner
        owner = msg.sender;
    }

    //kid structure
    //define kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    //dynamic kid array 
    Kid[] public kids;

    modifier onlyOwner(){
        //this can used for owner only methods as a require
        require(msg.sender == owner, "Only owner can add kids");
        _; //rest of the function where this was called
    }

    //add the kid
    //add kid to contract
    function addKid(address payable walletAddress,string memory firstName,string memory lastName,uint releaseTime,uint amount,bool canWithdraw) public onlyOwner{
        kids.push(Kid(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            amount,
            canWithdraw
        ));
    }

    //see the balance of the account
    function balanceOf() public view returns(uint){
        return address(this).balance;
    }

    //depsotie fund to contract, specifically to kids account
    //since this is a 'payable' function the deposite will happen automatically when we call the method
    function deposite(address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private {
        for(uint i = 0; i < kids.length; i++){
            if(kids[i].walletAddress == walletAddress){
                //add money, msg.value - amount we sent to the contract
                kids[i].amount += msg.value;

                //emit the event
                emit LogKidFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint){
        for(uint i = 0; i < kids.length; i++){
            if (kids[i].walletAddress ==  walletAddress){
                return i;
            }
        }
        return 999;
    }

    //kid checks if able to withdraw
    function availableToWithdraw(address walletAddress) public returns (bool) {
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].releaseTime, "You cannot withdraw yet");
        //check weather current time > release time -> can withdraw
        if(block.timestamp > kids[i].releaseTime){
            kids[i].canWithdraw = true;
            return true;
        }else{
            return false;
        }
    }

    //kid withdraw money
    function withdraw(address payable walletAddress) payable public{
        uint i = getIndex(walletAddress);
        //kid should be able to take out their money only
        //here msg.sender will be the method caller - kid trying to withdraw
        require(msg.sender == kids[i].walletAddress, "You must be the kid to withdraw");
        
        //also cannot withdraw until can withdraw is true
        require(kids[i].canWithdraw == true, "You are not able to withdraw at time");
        
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}