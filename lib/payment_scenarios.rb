# Don't call anything in PayPal::AdaptivePayments here.  Those methods
# are accessed indirectly through the payment model.  

module PaymentScenarios
  
  class SimplePayment
    
    def initialize(params)
      stu = "0.00"
      stu = params["stu"].to_money.format(:symbol => false) unless params["stu"].blank?
      @receivers = [{email: "stu_1321493496_per@thirdmode.com", amount: stu}]
    end
    
    def run(payment)
      payment.pay(@receivers)
    end

  end
  
  class SimplePaymentWithPaymentOptions
    
    def initialize(params)
      stu = "0.00"
      stu = params["stu"].to_money.format(:symbol => false) unless params["stu"].blank?
      @email = "stu_1321493496_per@thirdmode.com"
      @receivers = [{email: @email, amount: stu}]
    end
    
    def run(payment)
      response = payment.pay(@receivers)
      paykey = response["payKey"]
      payment.set_payment_options(paykey, @email)
      response # return response from the pay request XXX not good
    end

  end 
  
  class ParallelPayments
    
    def initialize(params)
      stu = "0.00"
      kira = "0.00"
      store = "0.00"
      stu = params["stu"].to_money.format(:symbol => false) unless params["stu"].blank?
      kira = params["kira"].to_money.format(:symbol => false) unless params["kira"].blank?
      store = params["store"].to_money.format(:symbol => false) unless params["store"].blank?
      @receivers = [
        {email: "stu_1321493496_per@thirdmode.com", amount: stu},
        {email: "kira_1321493810_per@thirdmode.com", amount: kira},
        {email: "store_1233166355_biz@thirdmode.com", amount: store}
      ]
    end
    
    def run(payment)
      payment.pay(@receivers)
    end
  end
  
  class ChainedPayments
    
    def initialize(params)
      stu = "0.00"
      kira = "0.00"
      store = "0.00"
      stu = params["stu"].to_money.format(:symbol => false) unless params["stu"].blank?
      kira = params["kira"].to_money.format(:symbol => false) unless params["kira"].blank?
      store = params["store"].to_money.format(:symbol => false) unless params["store"].blank?
      @receivers = [
        {email: "stu_1321493496_per@thirdmode.com", amount: stu, primary: "false"},
        {email: "kira_1321493810_per@thirdmode.com", amount: kira, primary: "false"},
        {email: "store_1233166355_biz@thirdmode.com", amount: "store", primary: "true"}
      ]
    end
    
    def run(payment)
      payment.pay(receivers)
    end
  end
  
  class Preapproval
    
    def initialize(params)
      s = params[:start_date]
      @start_date = DateTime.new(s[:year].to_i, s[:month].to_i,
        s[:day].to_i, s[:hour].to_i, s[:minute].to_i)
      s = params[:end_date]
      @end_date = DateTime.new(s[:year].to_i, s[:month].to_i,
        s[:day].to_i, s[:hour].to_i, s[:minute].to_i)
      @max_payments = params["max_payments"]
      @max_total = params["max_total"].to_money.format(:symbol => false)      
    end
    
    def run(payment)
      payment.preapproval(@start_date, @end_date, @max_total, 
        @max_payments)
    end
  end
  
end
