class UserSubparagraphsController < ApplicationController
  def index
    @user_subparagraphs = UserSubparagraph.all
  end
  
  def show
    @user_subparagraph = UserSubparagraph.find(params[:id])
  end
  
  def new
    @user_paragraph = UserParagraph.find(params[:user_paragraph_id])
    if @user_paragraph.part_article != nil 
      @job = @user_paragraph.part_article.specification_section.specification.job
      @specification_section = @user_paragraph.part_article.specification_section
    else
      @job = @user_paragraph.user_article.specification_section.specification.job
      @specification_section = @user_paragraph.user_article.specification_section
    end
    @client = @job.client
    @has_subparagraphs = UserSubparagraph.user_paragraph_id_eq(@user_paragraph.id)
    #@subparagraphs = UserSubparagraph.user_id_eq(as_user).user_paragraph_part_article_specification_section_specification_job_id_does_not_equal(@job.id).user_paragraph_part_article_specification_section_section_id_eq(@specification_section.section.id).all(:order => "created_at DESC")
    @user_subparagraph = UserSubparagraph.new(:user_paragraph_id => params[:user_paragraph_id])
  end
  
  def create
    @user_paragraph = UserParagraph.find(params[:user_subparagraph][:user_paragraph_id])
    if @user_paragraph.part_article != nil 
      @job = @user_paragraph.part_article.specification_section.specification.job
      @specification_section = @user_paragraph.part_article.specification_section
    else
      @job = @user_paragraph.user_article.specification_section.specification.job
      @specification_section = @user_paragraph.user_article.specification_section
    end
    @client = @job.client
    @user_subparagraph = UserSubparagraph.new(params[:user_subparagraph])
    @user_subparagraph.user_id = current_user.id
    if @user_subparagraph.save
      @specification_section.touch
      flash[:notice] = "Successfully created user subparagraph."
      redirect_to new_user_subparagraph_path(:user_paragraph_id => @user_paragraph.id, :collaborator_id => params[:collaborator_id])
    else
      render :action => 'new'
    end
  end
  
  def edit
    @user_subparagraph = UserSubparagraph.find(params[:id])
    @user_paragraph = @user_subparagraph.user_paragraph
    if @user_paragraph.part_article != nil 
      @job = @user_paragraph.part_article.specification_section.specification.job
      @specification_section = @user_paragraph.part_article.specification_section
    else
      @job = @user_paragraph.user_article.specification_section.specification.job
      @specification_section = @user_paragraph.user_article.specification_section
    end
    @client = @job.client
    @has_subparagraphs = UserSubparagraph.user_paragraph_id_eq(@user_paragraph.id)
  end
  
  def update
    @user_subparagraph = UserSubparagraph.find(params[:id])
    @user_paragraph = @user_subparagraph.user_paragraph
    if @user_paragraph.part_article != nil 
      @job = @user_paragraph.part_article.specification_section.specification.job
      @specification_section = @user_paragraph.part_article.specification_section
    else
      @job = @user_paragraph.user_article.specification_section.specification.job
      @specification_section = @user_paragraph.user_article.specification_section
    end
    @client = @job.client
    @has_subparagraphs = UserSubparagraph.user_paragraph_id_eq(@user_paragraph.id)
    if @user_subparagraph.update_attributes(params[:user_subparagraph])
      @specification_section.touch
      flash[:notice] = "Successfully updated user subparagraph."
      redirect_to new_user_subparagraph_path(:user_paragraph_id => @user_paragraph.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user_subparagraph = UserSubparagraph.find(params[:id])
    @user_paragraph = @user_subparagraph.user_paragraph
    @user_subparagraph.destroy
    flash[:notice] = "User subparagraph successfully removed."
    redirect_to new_user_subparagraph_path(:user_paragraph_id => @user_paragraph.id)
  end
end
