require 'payment_scenarios'

class PaymentsController < ApplicationController
  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.order('timestamp DESC').limit(10)
    @preapprovals = Preapproval.order('timestamp DESC').limit(10)
    @embedded_flow = false
    
    @payments.each do |pmt|
      if (pmt[:status].blank? || (pmt[:status] == 'CREATED')) &&
        (pmt[:scenario] == 'Payment')
          pmt.payment_details 
      end
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
   
    scenario_name = params[:payment][:scenario] 
    scenario = "PaymentScenarios/#{scenario_name}"
      .camelize.constantize.new(params)
  
    # Create a new Payment record and store it in the database.
    @payment = Payment.new(params[:payment])
    response = scenario.run(@payment)  
    if response.success? && @payment.save
      # Note we only save the record when PayPal returns success and
      # the record passes our own validators.
      @embedded_flow = !params["embedded_flow"].blank?
      if @embedded_flow
        @payments = Payment.order('timestamp DESC').limit(10)
        @paykey = response["payKey"]
        render action: "index"
      else
        if response["paymentExecStatus"] == "COMPLETED"
          # Preapproval was used.
          flash.now[:notice] = "Preapproved Payment was successful."
          @payments = Payment.order('timestamp DESC').limit(10)
          @preapprovals = Preapproval.order('timestamp DESC').limit(10)
          render action: "index"
        else
          # Payer needs to approve.
          redirect_to response.approve_url
        end
      end
    else
      flash.now[:error] = response.error_message unless response.success?
      @payments = Payment.order('timestamp DESC').limit(10)
      @preapprovals = Preapproval.order('timestamp DESC').limit(10)
      render action: "index"
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
