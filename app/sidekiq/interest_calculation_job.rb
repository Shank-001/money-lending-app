class InterestCalculationJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Starting interest calculation job"
    Loan.open.find_each do |loan|
      if loan.borrower.balance < loan.total_loan_amount
        loan.repayment
        Rails.logger.info "Loan ##{loan.id} fully repaid."
      else
        interest = (loan.total_loan_amount * loan.interest_rate / 100)
        loan.increment!(:total_loan_amount, interest)
        Rails.logger.info "Added interest ₹#{interest} to loan ##{loan.id}"
      end
    end
  end
end
