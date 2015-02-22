class Admin::SalesController < Admin::BaseController

  def index
    @good = Good.find params[:good_id]
    @sales = Sale.all

    respond_to do |format|
      format.html
      format.json { render json: @sales }
    end
  end

  def new
    @good = Good.find params[:good_id]
    @sale = Sale.new

    respond_to do |format|
      format.html
      format.json { render json: @sale }
    end
  end

  def create
    @good = Good.find params[:good_id]
    @sale = @good.sales.build sale_params

    respond_to do |format|
      if @sale.save
        format.html { redirect_to good_sales_url(params[:good_id]), notice: 'Sale was successfully created.' }
        format.json { render json: @sale, status: :created, location: @sale }
      else
        format.html { render action: "new" }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @sale = Sale.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @sale }
    end
  end

  def edit
    @good = Good.find params[:good_id]
    @sale = Sale.find(params[:id])
  end

  def update
    @sale = Sale.find(params[:id])

    respond_to do |format|
      if @sale.update sale_params
        format.html { redirect_to good_sales_url(@sale.good_id), notice: 'Sale was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sale = Sale.find(params[:id])
    @sale.destroy

    respond_to do |format|
      format.html { redirect_to sales_url }
      format.json { head :no_content }
    end
  end

  private
  def sale_params
    params[:sale].permit(:add_id)
  end
end
