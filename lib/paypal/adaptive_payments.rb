require 'money_utils'
# This is the only file in the application that knows about the PayPal
# JSON schema.  It is also the only file that calls the AdaptivePayments
# gem.
module Paypal
  module AdaptivePayments 
  
    def paypal_set_payment_options(paykey, receiver)
      doc = {
        requestEnvelope: {
          errorLanguage: "en_US"
        },
        payKey: paykey,
        senderOptions: {
          requireShippingAddressSelection: "true"
        },
        receiverOptions: {
          invoiceData: {
            item: [
              {
                identifier: "1",
                name: "Sample Product",
                itemCount: "1",
                itemPrice: "10.00",
                price: "10.00"
              }
            ],
            totalShipping: "0.00"
          },
          receiver: {
            email: receiver
          },
        },
      }
      pay_request = PaypalAdaptive::Request.new("test")
      pay_request.set_payment_options(doc) # return PayPal response
    end
    
    def paypal_get_payment_options(paykey)
      doc = {
        payKey: paykey,
        requestEnvelope: {
          errorLanguage: "en_US"
        }
      }
      request = PaypalAdaptive::Request.new("test")
      request.get_payment_options(doc)
    end
    
    def paypal_get_shipping_addresses(key)
      doc = {
        key: key, # payment or preapproval key
        requestEnvelope: {
          errorLanguage: "en_US"
        }
      }
      request = PaypalAdaptive::Request.new("test")
      request.get_shipping_addresses(doc)
    end
    
    #
    # Note that the 'senderEmail' is not required in this API.
    # A successful response includes a 'preapprovalKey' that
    # a payer uses to establish the preapproval relationship 
    # between the API caller and the payer.
    # 
    # start_date and end_date should be of class DateTime for the
    # strftime formatting to work.  Example, to start right now and
    # have the preapproval valid for 24 hours use:
    #   start_date = DateTime.now
    #   end_date = (DateTime.now + 1)
    #
      
    def paypal_preapproval(opts)
      doc = {
        returnUrl: "http://127.0.0.1:3000/payments",
        requestEnvelope: {errorLanguage: "en_US"},
        currencyCode: opts[:currency], 
        cancelUrl: "http://127.0.0.1:3000/payments",
        maxTotalAmountOfAllPayments: opts[:max_total_payments],
        maxAmountPerPayment: opts[:max_per_payment],
        maxNumberOfPayments: opts[:max_num_payments],
        maxNumberOfPaymentsPerPeriod: opts[:max_payments_per_period],
        paymentPeriod: opts[:payment_period],
        startingDate: opts[:start_date].localtime.iso8601, # strftime("%FT%T%:z"),
        endingDate: opts[:end_date].localtime.iso8601, # strftime("%FT%T%:z"),
        displayMaxTotalAmount: "true"
      }
      request = PaypalAdaptive::Request.new("test")
      request.preapproval(doc) # return PayPal response
    end
    
    def paypal_preapproval_details(preapproval_key, include_billing_address)
      doc = {
        requestEnvelope: {errorLanguage: "en_US"},
        getBillingAddress: (include_billing_address ? "true" : "false"), 
        preapprovalKey: preapproval_key
      }
      request = PaypalAdaptive::Request.new("test")
      request.preapproval_details(doc) # return PayPal response
    end
    
    # receivers should be an array of hashes of this form:
    # [
    #  {email: "stu_1321493496_per@thirdmode.com", amount: stu, primary: false},
    #  {email: "kira_1321493810_per@thirdmode.com", amount: kira, primary: false},
    #  {email: "store_1233166355_biz@thirdmode.com", amount: store, primary: true}
    # ]
    def paypal_pay(receivers, preapproval_key = nil)     
      doc = {
        returnUrl: "http://127.0.0.1:3000/payments",
        requestEnvelope: {errorLanguage: "en_US"},
        currencyCode: "USD",
        receiverList: {
          receiver: receivers,
        },
        cancelUrl: "http://127.0.0.1:3000",
        actionType: "PAY",
        # senderEmail: "buyer_1233697850_per@thirdmode.com", --causes embedded flow to fail
        trackingId: tracking_id
      }
      doc.merge!(preapprovalKey: preapproval_key) if preapproval_key
      
      request = PaypalAdaptive::Request.new("test")
      request.pay(doc) # return PayPal response
    end
    
    def paypal_payment_details(tracking_id)
      doc = {
        trackingId: tracking_id,
        requestEnvelope: {
          errorLanguage: "en_US"
        }
      }
      request = PaypalAdaptive::Request.new("test")
      request.payment_details(doc)
    end
  end
end