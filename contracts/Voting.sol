pragma solidity ^0.4.18;

// Create the consturctor for the Object

contract Voting{

  // Uses to store related data about the entity
  struct voter{
    address voterAddress;
    uint tokensBought;
    uint[] tokensUsedPerCandidate;
  }

  mapping (address => voter) public voterInfo;

  mapping (bytes32 => uint) public votesReceived;

  bytes32[] public candidatesList;

  uint public totalTokens;
  uint public balanceTokens;
  uint public tokenPrice; 

  // This is the actual constructor whih we can use to initiate the voting contract. We will set the price and the list of candidates.
  constructor (uint tokens, uint pricePerToken, bytes32[] candidateNames)public{
    candidatesList = candidateNames;
    totalTokens = tokens;
    balanceTokens = tokens;
    tokenPrice = pricePerToken;
  }

  function buy() payable public {
    // Sets the toal of the amount of tokens you want to buy
    // The value of the ether is set by msg.value
    // Based on the ether value and the token price we can find the total price and assign that to the voter.
    // THe buyers address is accessed through Message.sender
    uint tokensToBuy = msg.value / tokenPrice;
    require(tokensToBuy <= balanceTokens);
    voterInfo[msg.sender].voterAddress = msg.sender;
    voterInfo[msg.sender].tokensBought += tokensToBuy;
    balanceTokens -= tokensToBuy;
  }

  function totalVotesFor(bytes32 candidate) view public returns (uint) {
    return votesReceived[candidate];
  }

  function VoteForCandidate(bytes32 candidate, uint votesInTokens) public {
      uint index = indexOfCandidate(candidate);
      require(index != uint(-1));

      if(voterInfo[msg.sender].tokensUsedPerCandidate.length == 0){
        for(uint i=0; i < candidatesList.length; i++){
          voterInfo[msg.sender].tokensUsedPerCandidate.push(0);
        }
      }

      uint availableTokens = voterInfo[msg.sender].tokensBought - totalTokensUsed(voterInfo[msg.sender].tokensUsedPerCandidate);
      votesReceived[candidate] += votesInTokens;
      voterInfo[msg.sender].tokensUsedPerCandidate[index] += votesInTokens;
    }

    function totalTokensUsed(uint[] tokensUsedPerCandidate) private pure returns (uint){
      uint totalUsedTokens = 0;
      for(uint i = 0; i < tokensUsedPerCandidate.length; i++) {
        totalUsedTokens += tokensUsedPerCandidate[i];
      }
          return totalUsedTokens;
    }

    function indexOfCandidate(bytes32 candidate) view public returns (uint){
      for(uint i = 0; i < candidatesList.length; i++){
        if(candidatesList[i] == candidate){
          return i;
        }
      }
      return uint(-1); 
    }

    function tokensSold() view public returns (uint) {
      return totalTokens - balanceTokens;
    }

    function voterDetails(address user) view public returns (uint, uint[]) {
      return (voterInfo[user].tokensBought, voterInfo[user].tokensUsedPerCandidate);
    }

    function transferTo(address account) public {
      require(address(this).balance >= 0);
      account.transfer(this.balance);
    }

    function allCandidates() view public returns (bytes32[]) {
      return candidatesList;
    }
}


