class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :scenario
      t.string :paykey
      t.string :preapproval_key
      t.integer :amount # in cents for USD
      t.string :correlation_id
      t.string :status # same as payment_exec_status
      t.string :sender_email
      t.datetime :timestamp
      t.string :tracking_id
      t.text :details
      t.string :currency
      
      # For preapprovals
      t.integer :max_num_payments
      t.integer :max_total_payments
      t.integer :max_per_payment
      t.datetime :start_date
      t.datetime :end_date
      t.string :payment_period
      t.integer :max_payments_per_period
    end
  end
end
