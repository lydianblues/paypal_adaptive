require 'money_utils'
require 'date'

# Don't call anything in PayPal::AdaptivePayments here.  Those methods
# are accessed indirectly through the payment model.  

module PaymentScenarios
  
    
  class SimplePaymentWithPaymentOptions
    
    def initialize(params)
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
    def initialize(params)
      compute_receivers(params)
    end
    
    def run(payment)
      payment.pay(@receivers)
    end
    
    private
    
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
    
  class Preapproval
    
    def initialize(params)
      s = params[:start_date]
      @start_date = DateTime.new(s[:year].to_i, s[:month].to_i,
        s[:day].to_i, s[:hour].to_i, s[:minute].to_i, 0, DateTime.now.zone)
      s = params[:end_date]
      @end_date = DateTime.new(s[:year].to_i, s[:month].to_i,
        s[:day].to_i, s[:hour].to_i, s[:minute].to_i, 0, DateTime.now.zone)
      @max_per_payment = params["max_per_payment"].to_money.format(:symbol => false)
      @max_num_payments = params["max_num_payments"]
      @max_total_payments = params["max_total_payments"].to_money.format(:symbol => false)       
    end
    
    def run(payment)
      payment.preapproval(@start_date, @end_date, @max_per_payment, 
        @max_total_payments, @max_num_payments)
    end
  end
    
end
