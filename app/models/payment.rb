class Payment < ActiveRecord::Base
  
  before_create :init_payment
  
  # A payment is created with respect to a particular payment scenario.
  validates_presence_of :scenario
  
  serialize :details
  
  def get_payment_key(stu_amt = nil, kira_amt = nil, store_amt = nil)
    stu = "0.00"
    kira = "0.00"
    store = "0.00"
    stu = stu_amt.to_money.format(:symbol => false) unless stu_amt.blank?
    kira = kira_amt.to_money.format(:symbol => false) unless kira_amt.blank?
    store = store_amt.to_money.format(:symbol => false) unless store_amt.blank?
  
    doc = case scenario
    when 1 then {
      returnUrl: "http://127.0.0.1:3000",
      requestEnvelope: {errorLanguage: "en_US"},
      currencyCode: "USD",
      receiverList: {
        receiver: [
          {email: "stu_1321493496_per@thirdmode.com", amount: stu},
          {email: "kira_1321493810_per@thirdmode.com", amount: kira},
          {email: "store_1233166355_biz@thirdmode.com", amount: store}
        ]
      },
      cancelUrl: "http://127.0.0.1:3000",
      actionType: "PAY",
      # senderEmail: "buyer_1233697850_per@thirdmode.com", --causes embedded flow to fail
      trackingId: tracking_id
    }
    when 2 then
    {
      returnUrl: "http://127.0.0.1:3000", 
      requestEnvelope: {errorLanguage: "en_US"},
      currencyCode: "USD",  
      receiverList: {
        receiver: [
          {email: "stu_1321493496_per@thirdmode.com", amount: stu, primary: "false"},
          {email: "kira_1321493810_per@thirdmode.com", amount: kira, primary: "false"},
          {email: "store_1233166355_biz@thirdmode.com", amount: store, primary: "true"}
        ]
      },
      cancelUrl: "http://127.0.0.1:3000", 
      actionType: "PAY",
      # senderEmail: "buyer_1233697850_per@thirdmode.com", -- causes embedded flow to fail
      trackingId: tracking_id
    } 
    else
      raise "Invalid Scenario"
    end
  
    pay_request = PaypalAdaptive::Request.new("test")
    pay_request.pay(doc) # return PayPal response
  end
  
  def get_payment_details
    doc = {
      trackingId: tracking_id,
      requestEnvelope: {
        errorLanguage: "en_US"
      }
    }
    @pay_request = PaypalAdaptive::Request.new("test")
    pp_response = @pay_request.payment_details(doc)
    logger.info pp_response.to_yaml
    if (pp_response.success?)
      status = pp_response["status"]
      ts =  pp_response["responseEnvelope"]["timestamp"]
      email = pp_response["senderEmail"]
      timestamp = Time.parse(ts)
      paykey = pp_response["payKey"]
      cid = pp_response["responseEnvelope"]["correlationId"]
      raise pp_response.to_yaml if status.blank?
      
      total = 0.0
      pp_response["paymentInfoList"]["paymentInfo"].each do |pi|
        amt = pi["receiver"]["amount"].to_f
        if pi["receiver"]["primary"] == "true"
          total = amt
          break
        end
        total += amt
      end
      total = total.to_money.format
      update_attributes!(timestamp: timestamp, status: status, amount: total,
        sender_email: email, paykey: paykey, correlation_id: cid,
        details: pp_response)
    else
      raise "PaymentDetails failed: #{error_message(pp_response)}"
    end
  end
  
  def init_payment
    # This is temporary.  We should create a sequence in the database.  TODO.
    # Generate a random 12 digit invoice number not starting with a zero.
    rng = Random.new
    self.tracking_id = rng.rand(10**11..10**12 - 1)
  end
  
  def error_message(resp)
    msg = resp["error"][0]["message"]
  end
  
end
