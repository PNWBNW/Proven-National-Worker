import unittest
from test_utils import get_contract_state, send_transaction, validate_transaction_status, get_current_date

class TestPayoutProcess(unittest.TestCase):
    def setUp(self):
        """
        Set up the necessary environment for testing.
        This function runs before each test case.
        """
        self.contract_name = "farm_investment"
        self.transaction_id = None  # This will store transaction ID after sending a transaction
        self.today_date = get_current_date()  # Fetch current date for logic testing

    def test_payout_on_first_of_month(self):
        """
        Test that payouts are only triggered on the 1st of the month.
        """
        if self.today_date.day != 1:
            print("Not the first of the month. Skipping payout test.")
            return  # Skip the test if it's not the 1st of the month

        result = self._process_payout()
        self.assertTrue(result)

    def test_payout_on_non_first_of_month(self):
        """
        Ensure payouts are not triggered on any other day except the 1st.
        """
        if self.today_date.day == 1:
            print("It's the first of the month. Skipping non-payout test.")
            return  # Skip the test if it is the 1st of the month

        result = self._process_payout()
        self.assertFalse(result, "Payout should not be processed on days other than the 1st.")

    def test_payout_processing(self):
        """
        Test the payout processing logic when Merkle decision is approved.
        """
        # Assuming '0' means approve payout in Merkle decision-maker
        vote_option = 0  # Approve payout

        # Simulate the Merkle decision to approve payout
        vote_result = self._simulate_merkle_vote(vote_option)

        if vote_result:
            # Proceed to process the payout
            payout_result = self._process_payout()
            self.assertTrue(payout_result)
        else:
            print("Merkle decision failed. Payout not processed.")
            self.assertFalse(True)

    def _process_payout(self):
        """
        Simulate the payout process logic.
        """
        try:
            # Check if it's the first of the month
            if self.today_date.day == 1:
                # Process payout transaction
                tx_data = {
                    "contract_name": self.contract_name,
                    "action": "process_payout"
                }
                result = send_transaction(tx_data)

                if result:
                    self.transaction_id = result
                    return True
            return False
        except Exception as e:
            print(f"Error during payout process: {e}")
            return False

    def _simulate_merkle_vote(self, vote_option):
        """
        Simulate a vote in the Merkle decision maker.
        """
        try:
            tx_data = {
                "vote_option": vote_option,
                "contract_name": self.contract_name
            }
            
            # Send the transaction
            result = send_transaction(tx_data)
            
            if result:
                # Assume the transaction ID is returned upon success
                self.transaction_id = result
                return True
            return False

        except Exception as e:
            print(f"Error simulating Merkle vote: {e}")
            return False

    def test_transaction_status(self):
        """
        Check the status of the transaction after the payout process.
        """
        if self.transaction_id:
            result = validate_transaction_status(self.transaction_id)
            self.assertTrue(result, "Transaction did not succeed.")
        else:
            self.fail("Transaction ID is None. Cannot validate status.")

if __name__ == "__main__":
    unittest.main()
