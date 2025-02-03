import DateTime;
import MerkleHelper;
import NetworkStatus;
import AleoNetwork;

contract FarmInvestment {

    state payout_last_processed: DateTime;
    state total_investment: field;  // Total funds to be paid out
    state farm_id: u64;

    // Function to process farm investment payouts
    public fun processFarmInvestmentPayout(proof: vector<field>, leaf: field) -> string {
        // Check if it's the 1st of the month
        if (!self.isPayoutDay()) {
            return "Payouts are only allowed on the 1st of each month";
        }

        // Check network health before proceeding
        if (!self.isNetworkHealthy()) {
            return "Network congestion detected: SubDAO vote required";
        }

        // Ensure the payout is executed on the Aleo chain
        if (!self.isAleoNetwork()) {
            return "Payouts can only be processed on the Aleo chain";
        }

        // Verify the Merkle proof before proceeding with the payout logic
        let contract_decision = MerkleHelper::verifyMerkleProof(MerkleHelper::getMerkleRoot(), leaf, proof);
        if (contract_decision != "farm_investment") {
            return "Invalid contract decision";
        }

        // Proceed with the payout process if conditions are met
        self.executePayout();
        return "Farm investment payout processed successfully";
    }

    // Function to execute payout
    private fun executePayout() {
        let payout_amount = self.total_investment;

        // Logic for executing the payout goes here
        // Transfer funds, update states, etc.
        self.total_investment = 0;  // Reset after payout
        self.payout_last_processed = DateTime::getCurrentDate();
    }

    // Function to check if today is the 1st of the month
    private fun isPayoutDay() -> bool {
        let today = DateTime::getCurrentDate();
        return today.day == 1;
    }

    // Function to check network health before executing payouts
    private fun isNetworkHealthy() -> bool {
        let gas_fee = NetworkStatus::getGasFee();
        let latency = NetworkStatus::getLatency();

        // Set a threshold for gas fees and latency
        return !(gas_fee > 2 * NetworkStatus::get30DayAvgGasFee() || latency > NetworkStatus::getHighLatencyThreshold());
    }

    // Function to check if the network is Aleo
    private fun isAleoNetwork() -> bool {
        // Assuming we have an Aleo-specific network check function
        return AleoNetwork::isCurrentChain("Aleo");
    }
}
