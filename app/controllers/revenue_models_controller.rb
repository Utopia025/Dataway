class RevenueModelsController < ApplicationController
  # require devise login for all pages, minus except specifiers
  before_filter :authenticate_user!, :except => [:index]
      
  # GET /revenue_models
  # GET /revenue_models.json
  def index
    @revenue_models = RevenueModel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @revenue_models }
    end
  end

  # GET /revenue_models/1
  # GET /revenue_models/1.json
  def show
    @revenue_model = RevenueModel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @revenue_model }
    end
  end

  # GET /revenue_models/new
  # GET /revenue_models/new.json
  def new
    @revenue_model = RevenueModel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @revenue_model }
    end
  end

  # GET /revenue_models/1/edit
  def edit
    @revenue_model = RevenueModel.find(params[:id])
  end

  # POST /revenue_models
  # POST /revenue_models.json
  def create
    @revenue_model = RevenueModel.new(params[:revenue_model])

    respond_to do |format|
      if @revenue_model.save
        format.html { redirect_to @revenue_model, notice: 'Revenue model was successfully created.' }
        format.json { render json: @revenue_model, status: :created, location: @revenue_model }
      else
        format.html { render action: "new" }
        format.json { render json: @revenue_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /revenue_models/1
  # PUT /revenue_models/1.json
  def update
    @revenue_model = RevenueModel.find(params[:id])

    respond_to do |format|
      if @revenue_model.update_attributes(params[:revenue_model])
        format.html { redirect_to @revenue_model, notice: 'Revenue model was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @revenue_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /revenue_models/1
  # DELETE /revenue_models/1.json
  def destroy
    @revenue_model = RevenueModel.find(params[:id])
    @revenue_model.destroy

    respond_to do |format|
      format.html { redirect_to revenue_models_url }
      format.json { head :no_content }
    end
  end
end
