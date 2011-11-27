class CreatePreapprovals < ActiveRecord::Migration
  def change
    create_table :preapprovals do |t|
      t.string :scenario
      t.datetime :timestamp
      t.string :preapproval_key
      t.integer :max_num_payments
      t.integer :max_total_payments
      t.integer :max_per_payment
      t.datetime :start_date
      t.datetime :end_date
      t.string :payment_period
      t.integer :max_payments_per_period
      t.text :details
      t.string :currency
      t.string :status
    end
  end
end
