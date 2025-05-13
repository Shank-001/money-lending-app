class Wallet < ApplicationRecord
  belongs_to :account
  
  validates :balance, numericality: { greater_than_or_equal_to: 0 }  
end