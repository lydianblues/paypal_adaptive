require 'paypal/adaptive_payments'

#
# In this file, the various methods are wrappers for PayPal methods.
# The wrappers are needed because they can get and set the state of
# the model.  The PayPal methods don't reference a Payment model 
# instance.
#
class Payment < ActiveRecord::Base
  
  include Paypal::AdaptivePayments
  
  before_create :init_payment
  
  # A payment is created with respect to a particular payment scenario.
  validates_presence_of :scenario
  
  serialize :details
  
  # Simple, parallel, or chained payments.
  def pay(receivers)
    paypal_pay(receivers)
    # Don't update the attributes here.  Let the IPN do it.
  end
  
  def preapproval(start_date = DateTime.now, end_date = DateTime.now + 1.day,
    max_per_payment = '50.00', max_total_payments = '100.00',
    max_num_payments = 1, currency = "USD")
    
    response = paypal_preapproval(start_date, end_date, max_per_payment,
      max_total_payments, max_num_payments, currency)
      
    if response.success?
      update_attributes!(preapproval_key: response["preapprovalKey"])
    end
    response
  end
  
  def preapproval_details(include_billing_address = false)
    response = paypal_preapproval_details(preapproval_key, include_billing_address)
    update_attributes!(details: response)
  end
  
  def cancel_preapproval
    
  end
  
  def confirm_preapproval
    
  end
  
  def payment_details
    response = paypal_payment_details(tracking_id)
    update_attributes!(
      timestamp: response.timestamp,
      status: response.status,
      amount: response.cents,
      sender_email: response.email,
      paykey: response.paykey,
      correlation_id: response.correlation_id,
      details: response)
  end
  
  def set_payment_options(receiver)
    paypal_set_payment_options(paykey, receiver)
  end
  
  def get_payment_options
    paypal_get_payment_options(paykey)
  end
   
  def get_shipping_addresses
    paypal_get_shipping_addresses(paykey)
  end
  
  def init_payment
    # This is temporary.  We should create a sequence in the database.  TODO.
    # Generate a random 12 digit invoice number not starting with a zero.
    rng = Random.new
    self.tracking_id = rng.rand(10**11..10**12 - 1)
  end
  
  
end
