class CreateWallet < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.references :account, null: false, foreign_key: true
      t.decimal :balance, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
