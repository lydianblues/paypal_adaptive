require 'money_utils'
require 'date'

# Don't call anything in PayPal::AdaptivePayments here.  Those methods
# are accessed indirectly through the payment model.  

module PaymentScenarios
  
  module Utils
    def compute_receivers(params)
      stu = nil
      kira = nil
      store = nil
      stu = params[:stu].to_money.format(:symbol => false) unless params[:stu].blank?
      kira = params[:kira].to_money.format(:symbol => false) unless params[:kira].blank?
      store = params[:store].to_money.format(:symbol => false) unless params[:store].blank?
      @receivers = []
      @receivers << {email: "stu_1321493496_per@thirdmode.com", amount: stu} if stu
      @receivers << {email: "kira_1321493810_per@thirdmode.com", amount: kira} if kira
      @receivers << {email: "store_1233166355_biz@thirdmode.com", amount: store} if store
      if params[:chained]
        @receivers[0].merge!(primary: "false")
        @receivers[1].merge!(primary: "false")
        @receivers[2].merge!(primary: "true")
      end
    end
  end
    
  class SimplePaymentWithPaymentOptions
    
    def initialize(params)
      params = params[:payment]
      stu = nil
      stu = params[:stu].to_money.format(:symbol => false) unless params[:stu].blank?
      @email = "stu_1321493496_per@thirdmode.com"
      @receivers = [{email: @email, amount: stu}]
      @scenario = Payment.new(params)
    end
    
    def run(payment)
      response = @scenario.run(payment)
      paykey = response["payKey"]
      payment.set_payment_options(paykey, @email)
      response # return response from the pay request XXX not good
    end
    
  end 
  
  class Payment
    include Utils
    
    def initialize(params)
      compute_receivers(params[:payment])
      @try_preapproval = params[:try_preapproval]
    end
    
    def run(payment)
      payment.pay(@receivers, @try_preapproval)
    end
    
  end
    
  class Preapproval
    def run(preapproval)
      preapproval.preapprove
    end
  end
  
  class PreApprovedPayment
    include Utils
    
    def initialize(params)
      compute_receivers(params)
      @preapproved = true
    end
    
    def run(payment)
      payment.pay(@receivers, @preapproved)
    end
    
  end
  
    
end
