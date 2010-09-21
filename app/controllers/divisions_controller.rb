class DivisionsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :support
  end
  def index
    @divisions = Division.all
  end
  
  def new
    @division = Division.new
  end
  
  def create
    @division = Division.new(params[:division])
    if @division.save
      flash[:notice] = "Successfully created division."
      redirect_to :action => "index"
    else
      render :action => 'new'
    end
  end
  
  def edit
    @division = Division.find(params[:id])
  end
  
  def update
    @division = Division.find(params[:id])
    if @division.update_attributes(params[:division])
      flash[:notice] = "Successfully updated division."
        redirect_to :action => "index"
    else
      render :action => 'edit'
    end
  end
  
  def show
    @division = Division.find(params[:id])
  end
  def destroy
    @division = Division.find(params[:id])
    @division.destroy
    flash[:notice] = "Division successfully destroyed."
   redirect_to :action => "index"
  end
end
