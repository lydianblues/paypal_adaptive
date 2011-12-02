#
# In this file, the various methods are wrappers for PayPal methods.
# The wrappers are needed because they can get and set the state of
# the model.  The PayPal methods don't reference a Payment model 
# instance.
#
class Payment < ActiveRecord::Base
  
  include Paypal::AdaptiveAdapter
  
  after_initialize :init_payment
  
  before_save :check_defaults
  
  # A payment is created with respect to a particular payment scenario.
  validates_presence_of :scenario
  
  serialize :details
  
  # Simple, parallel, or chained payments.
  def pay(receivers, try_preapproval = false)
    if try_preapproval
      key = Preapproval.latest_preapproval.preapproval_key
    else
      key = nil
    end
    paypal_pay(receivers, key)
    
    # Don't update the attributes here.  Let the IPN do it.
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
  
  def check_defaults
    currency = 'USD' if currency.blank?
  end
  
end
