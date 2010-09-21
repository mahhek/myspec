class SubparagraphsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
        allow :manager
        allow :team
  end
  def index
    @subparagraphs = Subparagraph.all
  end
  
  def show
    @subparagraph = Subparagraph.find(params[:id])
  end
  
  def new
     @parts = Part.find(:all)
     @job = Job.find(params[:job_id])
     @client = @job.client
     @specification_section = SpecificationSection.find(params[:specification_section_id])
     @article_paragraph = ArticleParagraph.find(params[:article_paragraph_id])
     @has_subparagraphs = Subparagraph.article_paragraph_id_eq(@article_paragraph.id)
     @subparagraphs =Subparagraph.article_paragraph_part_article_specification_section_specification_job_id_does_not_equal(@job.id).article_paragraph_part_article_specification_section_section_id_eq(@specification_section.section.id).article_paragraph_paragraph_id_eq(@article_paragraph.paragraph_id).all(:order => "created_at DESC")
     @subparagraph = Subparagraph.new(:article_paragraph_id => params[:article_paragraph_id])
  end
  
  def create
    @subparagraph = Subparagraph.new(params[:subparagraph])
    @article_paragraph = ArticleParagraph.find(params[:subparagraph][:article_paragraph_id])
    @specification_section = @article_paragraph.part_article.specification_section
    @job = @article_paragraph.part_article.specification_section.specification.job
    @subparagraph.user_id = current_user.id
    if @subparagraph.save
      @specification_section.touch
      flash[:notice] = "Successfully created subparagraph."
      redirect_to new_subparagraph_path(:job_id => @job.id, :specification_section_id => @specification_section.id, :article_paragraph_id => @article_paragraph.id, :collaborator_id => params[:collaborator_id])
    else
      params[:job_id] = @job.id
      params[:specification_section_id] = @specification_section.id
      params[:article_paragraph_id] = @article_paragraph.id
      render :action => 'new'
    end
  end
  
  def edit
    @parts = Part.find(:all)
      @job = Job.find(params[:job_id])
      @client = @job.client
      @specification_section = SpecificationSection.find(params[:specification_section_id])
      @article_paragraph = ArticleParagraph.find(params[:article_paragraph_id])
      @has_subparagraphs = Subparagraph.article_paragraph_id_eq(@article_paragraph.id)
      @subparagraphs =Subparagraph.user_id_eq(as_user).article_paragraph_part_article_specification_section_specification_job_id_does_not_equal(@job.id).article_paragraph_part_article_specification_section_section_id_eq(@specification_section.section.id).article_paragraph_paragraph_id_eq(@article_paragraph.paragraph_id).all(:order => "created_at DESC")
    @subparagraph = Subparagraph.find(params[:id])
  end
  
  def update
    @subparagraph = Subparagraph.find(params[:id])
    article_paragraph = ArticleParagraph.find(params[:subparagraph][:article_paragraph_id])
    @specification_section = article_paragraph.part_article.specification_section
    @job = article_paragraph.part_article.specification_section.specification.job
    @subparagraph.user_id = current_user.id
    if @subparagraph.update_attributes(params[:subparagraph])
      specification_section = @subparagraph.article_paragraph.part_article.specification_section
      job_id = @subparagraph.article_paragraph.part_article.specification_section.specification.job_id
      flash[:notice] = "Subparagraph successfully updated."
      specification_section.touch
      redirect_to new_subparagraph_path(:job_id => job_id, :specification_section_id => specification_section.id, :article_paragraph_id => article_paragraph.id, :collaborator_id => params[:collaborator_id])
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @subparagraph = Subparagraph.find(params[:id])
    specification_section = @subparagraph.article_paragraph.part_article.specification_section
    job_id = @subparagraph.article_paragraph.part_article.specification_section.specification.job_id
    article_paragraph = ArticleParagraph.find(@subparagraph.article_paragraph_id)
    @subparagraph.destroy
    flash[:notice] = "Subparagraph successfully removed."
    specification_section.touch
    redirect_to new_subparagraph_path(:job_id => job_id, :specification_section_id => specification_section.id, :article_paragraph_id => article_paragraph.id, :collaborator_id => params[:collaborator_id])
  end
end
