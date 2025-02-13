program raise_negotiation;

mapping worker_raise_requests:
    key address as worker;
    value struct RaiseRequest;

mapping employer_responses:
    key address as worker;
    value struct EmployerResponse;

mapping subdao_votes:
    key address as worker;
    value struct SubDAOVote;

mapping performance_benchmarks:
    key address as worker;
    value struct PerformanceBenchmark;

mapping scheduled_reviews:
    key address as worker;
    value u64; // Next scheduled review timestamp.

struct RaiseRequest:
    current_wage: u64;
    requested_wage: u64;
    justification: string;
    status: u8; // 0 = Pending, 1 = Approved, 2 = Rejected, 3 = Counteroffer;

struct EmployerResponse:
    decision: u8; // 1 = Accepted, 2 = Rejected, 3 = Counteroffer;
    new_wage: u64;
    reason: string;

struct SubDAOVote:
    votes_for: u64;
    votes_against: u64;
    final_decision: u8; // 1 = Approved, 2 = Denied, 3 = Counteroffer;

struct PerformanceBenchmark:
    benchmark_goal: string;
    target_wage: u64;
    status: u8; // 0 = Pending, 1 = Achieved;

function submit_raise_request(worker: address, current_wage: u64, requested_wage: u64, justification: string) -> bool {
    ensure requested_wage > current_wage;

    let request = RaiseRequest {
        current_wage,
        requested_wage,
        justification,
        status: 0
    };

    worker_raise_requests[worker] = request;
    return true;
}

function employer_response(worker: address, decision: u8, new_wage: u64, reason: string) -> bool {
    ensure decision == 1 || decision == 2 || decision == 3;
    ensure (decision != 3) || (new_wage > 0);

    let response = EmployerResponse {
        decision,
        new_wage,
        reason
    };

    employer_responses[worker] = response;

    if decision == 1 {
        // Approve raise and update payroll
        call payroll.update_worker_wage(worker, new_wage);
        worker_raise_requests[worker].status = 1;
    } else if decision == 2 {
        worker_raise_requests[worker].status = 2;
    } else if decision == 3 {
        worker_raise_requests[worker].status = 3;
    }

    return true;
}

function subdao_vote(worker: address, votes_for: u64, votes_against: u64) -> bool {
    let total_votes = votes_for + votes_against;
    ensure total_votes > 0;

    let final_decision = if votes_for > votes_against {
        1
    } else {
        2
    };

    let vote_result = SubDAOVote {
        votes_for,
        votes_against,
        final_decision
    };

    subdao_votes[worker] = vote_result;

    if final_decision == 1 {
        let approved_wage = worker_raise_requests[worker].requested_wage;
        call payroll.update_worker_wage(worker, approved_wage);
        worker_raise_requests[worker].status = 1;
    } else {
        worker_raise_requests[worker].status = 2;
    }

    return true;
}

function appeal_raise_decision(worker: address, appeal_reason: string) -> bool {
    ensure worker_raise_requests[worker].status == 2; // Ensure the request was denied before allowing an appeal.

    // Reset raise request status to allow for SubDAO reconsideration.
    worker_raise_requests[worker].status = 0;

    return true;
}

function set_performance_benchmark(worker: address, benchmark_goal: string, target_wage: u64) -> bool {
    let benchmark = PerformanceBenchmark {
        benchmark_goal,
        target_wage,
        status: 0
    };

    performance_benchmarks[worker] = benchmark;
    return true;
}

function verify_performance_benchmark(worker: address) -> bool {
    ensure performance_benchmarks.contains(worker);

    let mut benchmark = performance_benchmarks[worker];

    // Simulating a verification process (could later integrate API verification or employer input).
    benchmark.status = 1;

    // Automatically approve raise if benchmark is met.
    call payroll.update_worker_wage(worker, benchmark.target_wage);
    worker_raise_requests[worker].status = 1;

    return true;
}

function schedule_raise_review(worker: address, review_period: u64) -> bool {
    let next_review = get_block_time() + review_period;
    scheduled_reviews[worker] = next_review;

    return true;
}

function get_raise_status(worker: address) -> RaiseRequest {
    return worker_raise_requests[worker];
}
