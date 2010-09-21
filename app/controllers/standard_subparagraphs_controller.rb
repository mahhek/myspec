class StandardSubparagraphsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager, :except => [:destroy, :update, :create]
       allow logged_in
  end
  def index
    @standard_article_subparagraphs = StandardSubparagraph.all
  end
  
  def show
    @standard_article_subparagraph = StandardSubparagraph.find(params[:id])
  end
  
  def new
    @parts = Part.find(:all)
    
    @standard_section = StandardSection.find(params[:standard_section_id])
    @standard_article_paragraph = StandardArticleParagraph.find(params[:standard_article_paragraph_id])
    @has_subparagraphs = StandardSubparagraph.standard_article_paragraph_id_eq(@standard_article_paragraph.id)
    @standard_subparagraph = StandardSubparagraph.new(:standard_article_paragraph_id => @standard_article_paragraph.id)
    @standard_subparagraphs = StandardSubparagraph.standard_article_paragraph_standard_part_article_standard_section_user_id_eq(current_user.id).standard_article_paragraph_standard_part_article_standard_section_section_id_eq(@standard_section.section_id).standard_article_paragraph_standard_part_article_standard_section_id_does_not_equal(@standard_section.id).standard_article_paragraph_paragraph_id_eq(@standard_article_paragraph.paragraph_id).user_id_eq([as_user, current_user.id]).all(:order => "created_at DESC")
  end
  
  def create
    @standard_subparagraph = StandardSubparagraph.new(params[:standard_subparagraph])
    @standard_article_paragraph = StandardArticleParagraph.find(params[:standard_subparagraph][:standard_article_paragraph_id])
    @standard_section = @standard_article_paragraph.standard_part_article.standard_section
    @standard_subparagraph.user_id = current_user.id
    if @standard_subparagraph.save
      #@standard_section.touch
      flash[:notice] = "Successfully created subparagraph."
      redirect_to new_standard_subparagraph_path(:standard_section_id => @standard_section.id, :standard_article_paragraph_id => @standard_article_paragraph.id)
    else
      params[:standard_section_id] = @standard_section.id
      params[:standard_article_paragraph_id] = @standard_article_paragraph.id
      flash[:warning] = "You need to fill data correctly."
      redirect_to new_standard_subparagraph_path(:standard_section_id => @standard_section.id, :standard_article_paragraph_id => @standard_article_paragraph.id)
      #render :action => 'new'
    end
    # if @standard_article_subparagraph.save
    #       flash[:notice] = "Successfully created standard article subparagraph."
    #       redirect_to @standard_article_subparagraph
    #     else
    #       render :action => 'new'
    #     end
  end
  
  def edit
    @parts = Part.find(:all)
      @standard_section = StandardSection.find(params[:standard_section_id])
      @standard_article_paragraph = StandardArticleParagraph.find(params[:standard_article_paragraph_id])
      @has_subparagraphs = StandardSubparagraph.standard_article_paragraph_id_eq(@standard_article_paragraph.id)
      #@subparagraphs = StandardSubparagraph.standard_article_paragraph_standard_part_article_standard_section_specification_job_id_does_not_equal(@job.id).article_paragraph_paragraph_id_eq(@article_paragraph.paragraph_id).all(:order => "created_at DESC")
    @standard_subparagraphs = StandardSubparagraph.standard_article_paragraph_standard_part_article_standard_section_id_does_not_equal(@standard_section.id).standard_article_paragraph_paragraph_id_eq(@standard_article_paragraph.paragraph_id).all(:order => "created_at DESC")
    @standard_subparagraph = StandardSubparagraph.find(params[:id])
  end
  
  def update
    @standard_subparagraph = StandardSubparagraph.find(params[:id])
    standard_article_paragraph = StandardArticleParagraph.find(params[:standard_subparagraph][:standard_article_paragraph_id])
    @specification_section = standard_article_paragraph.standard_part_article.standard_section
    @standard_subparagraph.user_id = current_user.id
    if @standard_subparagraph.update_attributes(params[:standard_subparagraph])
      standard_section = @standard_subparagraph.standard_article_paragraph.standard_part_article.standard_section
      flash[:notice] = "Successfully updated standard article subparagraph."
      redirect_to new_standard_subparagraph_path(:standard_section_id => standard_section.id, :standard_article_paragraph_id => standard_article_paragraph.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @standard_article_subparagraph = StandardSubparagraph.find(params[:id])
    standard_article_paragraph =  @standard_article_subparagraph.standard_article_paragraph
    standard_section = @standard_article_subparagraph.standard_article_paragraph.standard_part_article.standard_section
    @standard_article_subparagraph.destroy
    flash[:notice] = "Standard subparagraph successfully removed."
    redirect_to new_standard_subparagraph_path(:standard_section_id => standard_section.id, :standard_article_paragraph_id => standard_article_paragraph.id)
  end
end
