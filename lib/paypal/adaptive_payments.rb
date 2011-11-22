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
    def paypal_preapproval(start_date, end_date, max_total,
      max_payments, currency)
      doc = {
        returnUrl: "http://127.0.0.1:3000/payments",
        requestEnvelope: {errorLanguage: "en_US"},
        currencyCode: currency, 
        cancelUrl: "http://127.0.0.1:3000/payments",
        maxTotalAmountOfAllPayments: max_total,
        maxNumberOfPayments: max_payments,
        startingDate: start_date.strftime("%FT%T%:z"),
        endingDate: end_date.strftime("%FT%T%:z")
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
    def paypal_pay(receivers)     
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

        cents = 0
        pp_response["paymentInfoList"]["paymentInfo"].each do |pi|
          amt = MoneyUtils.paypal_to_cents(pi["receiver"]["amount"])
          if pi["receiver"]["primary"] == "true"
            cents = amt
            break
          end
          cents += amt
        end

        update_attributes!(timestamp: timestamp, status: status, amount: cents,
          sender_email: email, paykey: paykey, correlation_id: cid,
          details: pp_response)
      else
        raise "paypal_payment_details failed: #{error_message(pp_response)}"
      end
    end
         
    private
    
    def error_message(resp)
      msg = resp["error"][0]["message"]
    end
    
    
  end
end