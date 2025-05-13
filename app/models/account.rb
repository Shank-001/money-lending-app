class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :setup_wallet

  has_many :given_loans, class_name: 'Loan', foreign_key: 'lender_id'
  has_many :taken_loans, class_name: 'Loan', foreign_key: 'borrower_id'

  has_one :wallet, dependent: :destroy

  delegate :balance, to: :wallet

  enum role: { user: 0, admin: 1 }

  private

  def setup_wallet
    initial_balance = admin? ? 1000000 : 10000
    create_wallet(balance: initial_balance)
  end
end
