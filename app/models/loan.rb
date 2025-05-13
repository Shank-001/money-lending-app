class Loan < ApplicationRecord
  has_paper_trail(
    on: [:update],
    ignore: [:total_loan_amount, :updated_at],
    skip: [:total_loan_amount, :updated_at]
  )

  belongs_to :lender, class_name: 'Account', foreign_key: 'lender_id'
  belongs_to :borrower, class_name: 'Account', foreign_key: 'borrower_id'

  enum status: {
    requested: 0,
    approved: 1,
    open: 2,
    closed: 3,
    rejected: 4,
    waiting_for_adjustment_acceptance: 5,
    readjustment_requested: 6
  }

  validates :amount, numericality: { greater_than_or_equal_to: 100, less_than_or_equal_to: 100000 }  
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :lender_must_be_admin
  validate :borrower_must_be_user

  def accept
    lender.wallet.decrement!(:balance, amount)
    borrower.wallet.increment!(:balance, amount)
    update!(status: :open, total_loan_amount: amount)
  end

  def repayment
    if borrower.balance >= total_loan_amount
      borrower.wallet.decrement!(:balance, total_loan_amount)
      lender.wallet.increment!(:balance, total_loan_amount)
      update!(status: :closed)
    else
      lender.wallet.increment!(:balance, borrower.balance)
      borrower.wallet.update!(balance: 0.0)
      update!(status: :closed)
    end
  end

  private

  def lender_must_be_admin
    errors.add(:lender, 'must be an admin') unless lender&.admin?
  end

  def borrower_must_be_user
    errors.add(:borrower, 'must be a user') unless borrower&.user?
  end    
end