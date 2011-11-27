class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :scenario
      t.string :paykey
      t.integer :amount # in cents for USD
      t.string :status # same as payment_exec_status
      t.string :sender_email
      t.datetime :timestamp
      t.string :tracking_id
      t.text :details
      t.string :currency
    end
  end
end
