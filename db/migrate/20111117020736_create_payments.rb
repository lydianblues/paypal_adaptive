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
    end
  end
end
