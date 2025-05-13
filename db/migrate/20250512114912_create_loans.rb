class CreateLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :loans do |t|
      t.references :lender,   null: false, foreign_key: { to_table: :accounts }
      t.references :borrower, null: false, foreign_key: { to_table: :accounts }

      t.decimal :amount,        precision: 15, scale: 2, null: false
      t.decimal :interest_rate, precision: 5,  scale: 2, null: false
      t.decimal :total_loan_amount, precision: 15, scale: 2, default: 0.0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
