pragma solidity ^0.4.24;
import "@gnosis.pm/pm-contracts/contracts/Tokens/Token.sol";
import "./OutcomeToken.sol";
import "./Proxy.sol";
import "@josojo/realitytoken-contracts/contracts/RealityToken.sol";
import "@josojo/realitycheck-contracts/contracts/RealityCheck.sol";


contract EventData {

    /*
     *  Events
     */
    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);
    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);
    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);
    event WinningsRedemption(address indexed receiver, uint winnings, bytes32 branch);

    mapping(bytes32 => int) branch_outcome;
    mapping(bytes32 => bool) is_branch_outcome_set;

    /*
     *  Storage
     */
    OutcomeToken[] public outcomeTokens;


    RealityToken public realityToken;
    bytes32 public collateralBranch;
    bytes32 public questionId;
    RealityCheck realityCheck;


    //OutcomeTokenMeta[] public outcomeTokens;
}

/// @title Event contract - Provide basic functionality required by different event types
/// @author Stefan George - <stefan@gnosis.pm>
contract Event is EventData {


    /*
     *  Public functions
     */
    /// @dev Buys equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1
    /// @param collateralTokenCount Number of collateral tokens
    function buyAllOutcomes(uint collateralTokenCount)
        public
    {
        // Transfer collateral tokens to events contract
        require(realityToken.transferFrom(msg.sender, this, collateralTokenCount, collateralBranch));
        // Issue new outcome tokens to sender
        for (uint8 i = 0; i < outcomeTokens.length; i++)
            outcomeTokens[i].issue(msg.sender, collateralTokenCount);
        OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);
    }

    /// @dev Sells equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1
    /// @param outcomeTokenCount Number of outcome tokens
    function sellAllOutcomes(uint outcomeTokenCount)
        public
    {  
          // Revoke sender's outcome tokens of all outcomes
        for (uint8 i = 0; i < outcomeTokens.length; i++)
            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);
        // Transfer collateral tokens to sender
        require(realityToken.transfer(msg.sender, outcomeTokenCount, collateralBranch));
        OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);
    }

    function setOutcome(bytes32 branch, bytes32 contentHash, bytes32 rcQuestionID, uint256 minBond, uint256 minTimeout, address arbitrator) {
          require(questionId == keccak256(contentHash, minBond, minTimeout);
          require(realityToken.isWhitelisted(arbitrator, branch);          
          outcome = realityCheck.getFinalAnswerIfMatches(
                rcQuestionID,
                contentHash,
                arbitrator,
                minTimeout,
                minBond
          );
          branch_outcome[branch] = int(outcome);
          is_branch_outcome_set[branch] = true;
        
    }

 
    /// @dev gets winning event outcome
    /// @param branch is the branch on which a user wants to know the result
    function getOutcome(bytes32 branch)
        public
        view
        returns (int outcome)
    {
          require(is_branch_outcome_set[branch]);
          return branch_outcome[branch];
    }

    /// @dev Returns outcome count
    /// @return Outcome count
    function getOutcomeCount()
        public
        view
        returns (uint8)
    {
        return uint8(outcomeTokens.length);
    }

    /// @dev Returns outcome tokens array
    /// @return Outcome tokens
    function getOutcomeTokens()
        public
        view
        returns (OutcomeToken[])
    {
        return outcomeTokens;
    }

    /// @dev Returns the amount of outcome tokens held by owner
    /// @return Outcome token distribution
    function getOutcomeTokenDistribution(address owner)
        public
        view
        returns (uint[] outcomeTokenDistribution)
    {
        outcomeTokenDistribution = new uint[](outcomeTokens.length);
        for (uint8 i = 0; i < outcomeTokenDistribution.length; i++)
            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);
    }

}
