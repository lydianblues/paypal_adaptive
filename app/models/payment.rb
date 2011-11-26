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
  
  before_save :check_defaults
  
  # A payment is created with respect to a particular payment scenario.
  validates_presence_of :scenario
  
  serialize :details
  
  # Simple, parallel, or chained payments.
  def pay(receivers, try_preapproval = false)
    if try_preapproval
      key = latest_preapproval
    else
      key = nil
    end
    paypal_pay(receivers, key)
    
    # Don't update the attributes here.  Let the IPN do it.
  end

  # Set up the preapproval.  This request does not identify the payer.  The
  # payer uses the preapproval key when connecting to PayPal to approve the
  # request in the browser.  PayPal uses the login identity and the key to
  # establish the preapproval relationship between the payer and receiver.
  #
  # Subsequently, we have to arrange to send the preapproval key along with
  # the pay request.  We really need a site login facility to handle this
  # properly.  When we generate a preapproval, we know the user's identity,
  # and we'll save the user's identity under this preapproval key.  In the
  # demo there is only one payer, the buyer* PayPal login. When the payer
  # indicates that the pay API should use a preapproval, we'll send along
  # the preapproval key from the most recent Payment record.
  #
      
  def preapproval
    opts = {
      start_date: start_date || DateTime.now,
      end_date: end_date || DateTime.now + 1.day,
      max_per_payment: MoneyUtils.format_for_paypal(max_per_payment),
      max_total_payments: MoneyUtils.format_for_paypal(max_total_payments),
      max_num_payments: max_num_payments || 1,
      payment_period: payment_period || 'MONTHLY',
      max_payments_per_period: max_payments_per_period || 1,
      currency: currency || 'USD'
    }
    
    response = paypal_preapproval(opts)
    if response.success?
      update_attributes!(preapproval_key: response.preapproval_key,
        timestamp: response.timestamp)
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
  
  # Start date for preapprovals.
  def start_date=(d)
    unless d.blank?
      write_attribute(:start_date, DateTime.new(d[:year].to_i, d[:month].to_i,
        d[:day].to_i, d[:hour].to_i, d[:minute].to_i, 0, DateTime.now.zone))
    end
  end
  
  # End date for preapprovals.
  def end_date=(d)
    unless d.blank?
      write_attribute(:end_date, DateTime.new(d[:year].to_i, d[:month].to_i,
        d[:day].to_i, d[:hour].to_i, d[:minute].to_i, 0, DateTime.now.zone))
    end
  end
  
  def max_per_payment=(val)
    write_attribute(:max_per_payment, MoneyUtils.parse(val)) unless val.blank?
  end
  
  def max_total_payments=(val)
    write_attribute(:max_total_payments, MoneyUtils.parse(val)) unless val.blank?
  end
  
  def max_payments_per_period=(val)
    write_attribute(:max_payments_per_period, val.to_i) unless val.blank?
  end
  
  def init_payment
    # This is temporary.  We should create a sequence in the database.  TODO.
    # Generate a random 12 digit invoice number not starting with a zero.
    rng = Random.new
    self.tracking_id = rng.rand(10**11..10**12 - 1)
  end
  
  def check_defaults
    start_date = DateTime.now if start_date.blank?
    end_date = DateTime.now + 1.day if end_date.blank?
    max_per_payment =  10000 if max_per_payment.blank?
    max_total_payments = 100000 if max_total_payments.blank?
    max_num_payments = 1 if max_num_payments.blank?
    payment_period ='MONTHLY' if payment_period.blank?
    max_payments_per_period = 1 if max_payments_per_period.blank?
    currency = 'USD' if currency.blank?
  end
  
  def latest_preapproval(sender = nil)
    # 'sender' is not used since we haven't implemented user accounts.
    Payment.where('preapproval_key IS NOT NULL').order('timestamp DESC').first
  end
  
  
end
