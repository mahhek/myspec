class SpecificationSectionsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       allow :team
  end
  
  def new
    @specification_section = SpecificationSection.new(:specification_id => params[:specification_id])
  end
  
  def create
    @specification_section = SpecificationSection.new(params[:specification_section])
    job = @specification_section.specification.job.id
    if @specification_section.save
      flash[:notice] = "Specification section successfully created."
      redirect_to job_path(job)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @specification_section = SpecificationSection.find(params[:id])
  end
  
  def update
    @specification_section = SpecificationSection.find(params[:id])
    if @specification_section.update_attributes(params[:specification_section])
      flash[:notice] = "Section successfully updated."
      redirect_to new_spec_sec_part_path(:job_id => @specification_section.specification.job.id, :specification_section_id => @specification_section.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @specification_section = SpecificationSection.find(params[:id])
    job = @specification_section.specification.job
    @specification_section.destroy
    flash[:notice] = "Section successfully removed."
    redirect_to job_path(job)
  end
  
  def destroy_share
    @collaborator = Collaborator.find(params[:collaborator_id])
    @specification_section = SpecificationSection.find(params[:id])
    job = @specification_section.specification.job
    @specification_section.destroy
    flash[:notice] = "Section successfully removed."
    redirect_to shared_job_path(:job_id => job.id, :collaborator_id => @collaborator.id)
  end
end
