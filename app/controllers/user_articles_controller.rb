class UserArticlesController < ApplicationController
  def index
    @user_articles = UserArticle.all
  end
  
  def show
    @user_article = UserArticle.find(params[:id])
  end
  
  def new
    @job = Job.find(params[:job_id])
    @client = @job.client
    @part = Part.find(params[:part_id])
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @user_article = UserArticle.new(:part_id => params[:part_id], :specification_section_id => params[:specification_section_id])
  end
  
  def create
    @user_article = UserArticle.new(params[:user_article])
    @specification_section = @user_article.specification_section
    @job = @specification_section.specification.job
    
    @user_article.user = current_user
    if @user_article.save
      flash[:notice] = "Successfully created user article."
      redirect_to new_user_article_path(:specification_section_id => @user_article.specification_section_id, :part_id => 1, :job_id => @user_article.specification_section.specification.job.id, :collaborator_id => params[:collaborator_id])
      #redirect_to new_spec_sec_part_path(:specification_section_id => @user_article.specification_section_id, :job_id => @user_article.specification_section.specification.job.id)
    else
      render :action => 'new'
    end
    
  end
  
  def edit
    @user_article = UserArticle.find(params[:id])
    @specification_section = @user_article.specification_section
    @job = @user_article.specification_section.specification.job
    @client = @job.client
  end
  
  def update
    @user_article = UserArticle.find(params[:id])
    if @user_article.update_attributes(params[:user_article])
      flash[:notice] = "Successfully updated user article."
      redirect_to new_user_article_path(:specification_section_id => @user_article.specification_section_id, :part_id => 1, :job_id => @user_article.specification_section.specification.job.id, :collaborator_id => params[:collaborator_id])
      #redirect_to new_spec_sec_part_path(:specification_section_id => @user_article.specification_section_id, :job_id => @user_article.specification_section.specification.job.id)
    else
      render :action => 'edit'
    end
  end
  def destroy_art
    @user_article = UserArticle.find(params[:id])
    @user_article.destroy
    flash[:notice] = "User article successfully removed."
    redirect_to new_user_article_path(:specification_section_id => @user_article.specification_section_id, :part_id => 1, :job_id => @user_article.specification_section.specification.job.id)
  end
  def destroy
    @user_article = UserArticle.find(params[:id])
    @user_article.destroy
    flash[:notice] = "User article successfully removed."
    redirect_to new_spec_sec_part_path(:specification_section_id => @user_article.specification_section_id, :job_id => @user_article.specification_section.specification.job.id)
  end
end
