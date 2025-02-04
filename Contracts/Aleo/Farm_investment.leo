// farm_investments.leo

// Import required libraries
import "std/contract.leo";

// Contract definition for farm investments
contract FarmInvestments {

    // Define the struct to store farm investment data
    struct FarmInvestment {
        address farmOwner;
        uint64 investmentAmount;
        bool payoutApproved;
        bool investmentComplete;
        uint64 payoutDate;
        string farmType; // E.g., "Organic", "Sustainable", etc.
    }

    // State variables
    public farmInvestmentsData: map<address, FarmInvestment>;
    public payoutQueue: vector<address>;
    public payoutStatus: map<address, bool>;

    // Events
    event InvestmentMade(farmOwner: address, amount: uint64);
    event PayoutApproved(farmOwner: address, payoutAmount: uint64);
    event PayoutDenied(farmOwner: address);
    event PayoutDelayed(farmOwner: address);

    // Function for making a farm investment
    public fun makeInvestment(farmOwner: address, amount: uint64, farmType: string) {
        // Ensure the investment is positive
        assert!(amount > 0, "Investment amount must be greater than zero");

        // Store the investment data
        self.farmInvestmentsData[farmOwner] = FarmInvestment {
            farmOwner: farmOwner,
            investmentAmount: amount,
            payoutApproved: false,
            investmentComplete: false,
            payoutDate: 0,  // Placeholder until payout date is set
            farmType: farmType
        };

        // Emit event for making an investment
        self.emit(InvestmentMade(farmOwner, amount));
    }

    // Function for SubDAO to approve payout to a farm
    public fun approvePayout(farmOwner: address, payoutAmount: uint64, currentDate: uint64) {
        // Ensure the farm investment exists
        assert!(self.farmInvestmentsData.contains(farmOwner), "Farm investment not found");

        // Check if the payout is approved already
        assert!(!self.farmInvestmentsData[farmOwner].payoutApproved, "Payout already approved");

        // Update the payout approval status
        self.farmInvestmentsData[farmOwner].payoutApproved = true;
        self.farmInvestmentsData[farmOwner].payoutDate = currentDate;

        // Add to the payout queue
        self.payoutQueue.push(farmOwner);

        // Emit the event
        self.emit(PayoutApproved(farmOwner, payoutAmount));
    }

    // Function for SubDAO to deny payout to a farm
    public fun denyPayout(farmOwner: address) {
        // Ensure the farm investment exists
        assert!(self.farmInvestmentsData.contains(farmOwner), "Farm investment not found");

        // Deny payout
        self.farmInvestmentsData[farmOwner].payoutApproved = false;

        // Emit the event
        self.emit(PayoutDenied(farmOwner));
    }

    // Function for SubDAO to delay payout
    public fun delayPayout(farmOwner: address) {
        // Ensure the farm investment exists
        assert!(self.farmInvestmentsData.contains(farmOwner), "Farm investment not found");

        // Delay payout
        self.emit(PayoutDelayed(farmOwner));
    }

    // Function to process the payout if the payout date has arrived
    public fun processPayout(farmOwner: address, currentDate: uint64) {
        // Ensure the farm investment exists
        assert!(self.farmInvestmentsData.contains(farmOwner), "Farm investment not found");

        // Check if payout is approved and the date has arrived
        if (self.farmInvestmentsData[farmOwner].payoutApproved && currentDate >= self.farmInvestmentsData[farmOwner].payoutDate) {
            // Process the payout (for example, transfer funds here)
            // Placeholder logic for payout processing
            self.farmInvestmentsData[farmOwner].investmentComplete = true;

            // Emit event
            self.emit(PayoutApproved(farmOwner, self.farmInvestmentsData[farmOwner].investmentAmount));
        }
    }

    // Function to check the status of a farm investment
    public fun checkInvestmentStatus(farmOwner: address): FarmInvestment {
        assert!(self.farmInvestmentsData.contains(farmOwner), "Farm investment not found");

        // Return farm investment data
        return self.farmInvestmentsData[farmOwner];
    }

    // Function to get the current payout queue
    public fun getPayoutQueue(): vector<address> {
        return self.payoutQueue;
    }

    // Function to check if a payout is ready for a specific farm
    public fun isPayoutReady(farmOwner: address, currentDate: uint64): bool {
        // Ensure the farm investment exists
        assert!(self.farmInvestmentsData.contains(farmOwner), "Farm investment not found");

        // Check if payout is approved and the date has arrived
        return self.farmInvestmentsData[farmOwner].payoutApproved && currentDate >= self.farmInvestmentsData[farmOwner].payoutDate;
    }
}
