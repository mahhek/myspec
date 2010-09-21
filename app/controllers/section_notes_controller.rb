class SectionNotesController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       allow :team
  end
  in_place_edit_for :section_note, :note
  def inc(specification_section_id)
    @specification_section = SpecificationSection.find(specification_section_id)
    #@job = Job.find(@specification_section.specification.job)
  end
  
  def index
    @job = Job.find(params[:job_id])
    @client = @job.client
    if params[:specification_section_id] != nil
      inc(params[:specification_section_id])
      @section_notes = SectionNote.specification_section_id_eq(params[:specification_section_id])
      @section_note = SectionNote.new(:specification_section_id => @specification_section.id)
    else
      @section_notes = SectionNote.specification_section_specification_job_id_eq(params[:job_id])
      @section_note = SectionNote.new
    end
  end
  
  def show
    @section_note = SectionNote.find(params[:id])
    inc(@section_note.specification_section_id)
  end
  
  def new
    @section_note = SectionNote.new
  end
  
  def create
    @section_note = SectionNote.new(params[:section_note])
    inc(@section_note.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    @section_note.user_id = current_user.id
    if @section_note.save
      @specification_section.touch
      flash[:notice] = "Successfully created section note."
      redirect_to section_notes_path(:job_id => @job.id, :specification_section_id => @specification_section.id, :collaborator_id => params[:collaborator_id])
    else
      render :action => 'new'
    end
  end
  
  def edit
    @section_note = SectionNote.find(params[:id])
    @job = @section_note.specification_section.specification.job
    @client = @job.client
    inc(@section_note.specification_section_id)
  end
  
  def update
    @section_note = SectionNote.find(params[:id])
    #@section_note.note = params[:value]
    #@section_note.save
    #@section_note.reload
    #render_text @section_note.note
     inc(@section_note.specification_section_id)
         @job = @specification_section.specification.job
         if @section_note.update_attributes(params[:section_note])
           @specification_section.touch
           flash[:notice] = "Successfully updated section note."
           redirect_to  section_notes_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
         else
           render :action => 'edit'
         end
  end
  
  def destroy
    @section_note = SectionNote.find(params[:id])
    inc(@section_note.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    @section_note.destroy
    flash[:notice] = "Successfully removed section note."
    @specification_section.touch
    redirect_to section_notes_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
  end
end
