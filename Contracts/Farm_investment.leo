import MerkleDecisionMaker;
import SubDAOVoting; // Importing SubDAO voting contract

contract FarmInvestment {
    // Farm investment balances
    state farm_balances: map<address, u64>;
    
    // Active SubDAO payout vote state
    state pending_votes: map<address, vector<u8>>; // Stores votes for each farm payout request

    // Function to allow investments
    public fun invest(farm: address, amount: u64) -> string {
        if (amount == 0) {
            return "Investment amount must be greater than zero";
        }
        self.farm_balances[farm] += amount;
        return "Investment successful";
    }

    // Function to process payout request
    public fun requestPayout(farm: address, proof: vector<field>, highGas: bool, networkIssue: bool) -> string {
        if (!self.farm_balances.contains_key(farm)) {
            return "Farm not found";
        }

        // If high gas fees or network issues exist, trigger SubDAO voting
        if (highGas || networkIssue) {
            return self.triggerSubDAOVote(farm, proof);
        }

        // Otherwise, proceed directly with Merkle proof verification
        return self.processPayout(farm, proof);
    }

    // Function to trigger SubDAO voting for payout decision
    private fun triggerSubDAOVote(farm: address, proof: vector<field>) -> string {
        let vote_id = SubDAOVoting::startVote(farm);
        self.pending_votes[farm] = vec![];
        return "SubDAO vote started for farm: " + farm.to_string();
    }

    // Function for SubDAO members to cast votes
    public fun castVote(farm: address, voter: address, vote_option: u8) -> string {
        if (!self.pending_votes.contains_key(farm)) {
            return "No active vote for this farm";
        }

        // Ensure vote_option is within 0-3 range
        if (vote_option > 3) {
            return "Invalid vote option";
        }

        let mut votes = self.pending_votes[farm];
        votes.push(vote_option);
        self.pending_votes[farm] = votes;

        // Check if majority vote has been reached
        if (SubDAOVoting::hasMajority(votes)) {
            return self.executeVoteDecision(farm);
        }

        return "Vote recorded";
    }

    // Function to execute payout based on vote results
    private fun executeVoteDecision(farm: address) -> string {
        let votes = self.pending_votes[farm];
        let result = SubDAOVoting::tallyVotes(votes);

        match result {
            0 => self.executeFarmPayout(farm),  // Approve Farm Investment Payout
            1 => "Redirected to Worker Identity Payout", // Approve Worker Identity Payout
            2 => "Payout Delayed by SubDAO", // Delay Payout
            3 => "Payout Denied by SubDAO", // Deny Payout
            _ => "Invalid Vote Outcome"
        }
    }

    // Function to execute a farm investment payout
    private fun executeFarmPayout(farm: address) -> string {
        let balance = self.farm_balances[farm];

        if (balance > 0) {
            self.farm_balances[farm] = 0; // Reset balance after payout
            return "Farm Payout Successful: Paid " + balance.to_string();
        } else {
            return "Insufficient funds for payout";
        }
    }

    // Function to check farm balance
    public fun getBalance(farm: address) -> u64 {
        return self.farm_balances.get_or_else(farm, 0);
    }
}
