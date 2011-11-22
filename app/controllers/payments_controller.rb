require 'payment_scenarios'

class PaymentsController < ApplicationController
  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.order('timestamp DESC').limit(30)
    @embedded_flow = false
    
    @payments.each do |pmt|
      # pmt.payment_details if pmt["status"].blank? || (pmt["status"] == 'CREATED')
      # N.B. preapprovals also are getting a payment record.  Do we want to do this?
      # Also the trackingId, when sent to PayPal will then generate an 
      #"invalidTrackingId" error.
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
    end
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.json
  def new
    @payment = Payment.new

     respond_to do |format|
       format.html # new.html.erb
       format.json { render json: @payment }
     end
  end

  # GET /payments/1/edit
  def edit
    @payment = Payment.find(params[:id])
  end

  # POST /payments
  # POST /payments.json
  def create
   
    scenario = params["scenario"] 
    begin
      klass = "PaymentScenarios/#{scenario}".camelize.constantize.new(params)
  
      # Create a new Payment record and store it in the database.
      @payment = Payment.create!(scenario: scenario)
      
      response = klass.run(@payment)
      
      if response.success?
        @embedded_flow = !params["embedded_flow"].blank?
        if @embedded_flow
          @payments = Payment.order('timestamp DESC').limit(30)
          @paykey = response["payKey"]
          render :action => :index
        elsif response.approve_paypal_payment_url
          redirect_to response.approve_paypal_payment_url
        else
          redirect_to payments_path
        end
      else
        raise response["error"][0]["message"]
      end
    rescue Exception => e
      Payment.delete(@payment.id) if @payment
      raise
      msg = e.message
      flash[:error] = msg
      @payments = Payment.order('timestamp DESC').limit(30)
      render :action => :index
    end

  end
  
  # PUT /payments/1
  # PUT /payments/1.json
  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :ok }
    end
  end
end
