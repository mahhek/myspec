class SpecificationsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       allow :team
  end
  
  def new
    @specification = Specification.new(:job_id => params[:job_id])
  end
  
  def create
    @specification = Specification.new(params[:specification])
    if @specification.save
      flash[:notice] = "Division successfully created."
      redirect_to job_path(@specification.job)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @specification = Specification.find(params[:id])
  end
  
  def update
    @specification = Specification.find(params[:id])
    if @specification.update_attributes(params[:specification])
      flash[:notice] = "Division successfully updated."
      redirect_to @specification
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @specification = Specification.find(params[:id])
    job= @specification.job
    @specification.destroy
    flash[:notice] = "Division successfully removed."
    redirect_to job_path(job)
  end
end
