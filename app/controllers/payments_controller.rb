class PaymentsController < ApplicationController
  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.order('timestamp DESC').limit(20)
    @embedded_flow = false
    
    @payments.each do |pmt|
      pmt.get_payment_details if pmt["status"].blank? || (pmt["status"] == 'CREATED')
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
    
    # Create a new Payment record and store it in the database.
    @payment = Payment.create!(scenario: params["scenario"])
    
    # Contact PayPal and get a payment key for the given values in the
    # given scenario.
    pp_response = @payment.get_payment_key(params["stu"], params["kira"],
      params["store"])
    
    if pp_response.success?
      @payments
      @embedded_flow = !params["embedded_flow"].blank?
      if @embedded_flow
        @payments = Payment.order('timestamp DESC').limit(20)
        @paykey = pp_response["payKey"]
        render :action => :index
      else
        redirect_to pp_response.approve_paypal_payment_url
      end
    else
      msg = pp_response["error"][0]["message"]
      flash[:error] = msg
      @payments = Payment.order('timestamp DESC').limit(20)
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
