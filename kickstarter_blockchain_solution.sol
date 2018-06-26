pragma solidity ^0.4.17;

contract CampaignFactory{
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
      address newCampaign =  new Campagin(minimum, msg.sender);
      deployedCampaigns.push(newCampaign);
    }
    
    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }
}
contract Campagin{
    mapping (address => uint) public timesrejected;
    mapping (address => uint) public timesapproved;
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;

    }
    Request [] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    modifier restricted(){
        require(msg.sender==manager);
        _;
    }
    
    constructor (uint minimum, address creator) public{
        manager=creator;
        minimumContribution=minimum;
    }
    
    function contribute() public payable{
        require(msg.value> minimumContribution);
        approvers[msg.sender]=true;
        approversCount++;
    }
    function createRequest(string description, uint value, address recipient) public restricted
    {
        Request memory newRequest= Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        }); 
        requests.push(newRequest); 
    }
    function approveRequest(uint index) public{
        Request storage request= requests[index];
        require(approvers[msg.sender]);
        require(!requests[index].approvals[msg.sender]);
        request.approvals[msg.sender]=true;
        request.approvalCount++;
    }
    function finalizeRequest(uint index) public restricted{
        Request storage request= requests[index];
        require(!requests[index].complete);
        if(request.approvalCount<(approversCount/2))
        {
         timesrejected[request.recipient]=++timesrejected[request.recipient];
        }
        require(request.approvalCount>(approversCount/2));
        
        timesapproved[request.recipient]=++timesapproved[request.recipient];
        
        request.recipient.transfer(request.value);
        requests[index].complete=true;
        
    }
}
