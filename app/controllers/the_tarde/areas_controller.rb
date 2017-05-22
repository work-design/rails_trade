class Admin::AreasController < Admin::BaseController

  def index
    @areas = Area.all

    respond_to do |format|
      format.html
      format.json { render json: @areas }
    end
  end

  def show
    @area = Area.find params[:id]

    respond_to do |format|
      format.html
      format.json { render json: @areas }
    end
  end

  def new
    @area = Area.new

    respond_to do |format|
      format.html
      format.json { render json: @area }
    end
  end


  def edit
    @area = Area.find(params[:id])
  end

  def create
    @area = Area.new area_params

    respond_to do |format|
      if @area.save
        format.html { redirect_to admin_areas_url, :notice => '地区添加成功' }
        format.json { render json: @area, status: :created, location: @area }
      else
        format.html { render action: "new" }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @area = Area.find(params[:id])

    respond_to do |format|
      if @area.update area_params
        format.html { redirect_to admin_area_url(@area), notice: 'Area was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @area = Area.find(params[:id])
    @area.destroy

    respond_to do |format|
      format.html { redirect_to areas_url }
      format.json { head :no_content }
    end
  end

  private
  def set_area

  end

  def area_params
    params[:area].permit(:parent_id, :name)
  end

end
