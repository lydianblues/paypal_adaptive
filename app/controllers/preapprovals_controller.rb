class PreapprovalsController < ApplicationController
  # GET /preapprovals
  # GET /preapprovals.json
  def index
    @preapprovals = Preapproval.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @preapprovals }
    end
  end

  # GET /preapprovals/1
  # GET /preapprovals/1.json
  def show
    @preapproval = Preapproval.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @preapproval }
    end
  end

  # GET /preapprovals/new
  # GET /preapprovals/new.json
  def new
    @preapproval = Preapproval.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @preapproval }
    end
  end

  # GET /preapprovals/1/edit
  def edit
    @preapproval = Preapproval.find(params[:id])
  end

  # POST /preapprovals
  # POST /preapprovals.json
  def create
    scenario_name = params[:preapproval][:scenario] 
    scenario = "PaymentScenarios/#{scenario_name}"
      .camelize.constantize.new(params)
  
    # Create a new Preapproval record and store it in the database.
    @preapproval = Preapproval.new(params[:preapproval])
    response = scenario.run(@preapproval)
      
    if response.success? && @preapproval.save
      redirect_to response.preapprove_url
    else
      flash.now[:error] = response.error_message unless response.success?
      @payments = Payment.order('timestamp DESC').limit(10)
      @preapprovals = Preapprovals.order('timestamp DESC').limit(10)
      render action: "index"
    end
    
  end

  # PUT /preapprovals/1
  # PUT /preapprovals/1.json
  def update
    @preapproval = Preapproval.find(params[:id])

    respond_to do |format|
      if @preapproval.update_attributes(params[:preapproval])
        format.html { redirect_to @preapproval, notice: 'Preapproval was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @preapproval.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /preapprovals/1
  # DELETE /preapprovals/1.json
  def destroy
    @preapproval = Preapproval.find(params[:id])
    @preapproval.destroy

    respond_to do |format|
      format.html { redirect_to preapprovals_url }
      format.json { head :ok }
    end
  end
end
