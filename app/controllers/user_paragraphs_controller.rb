class UserParagraphsController < ApplicationController
  def index
    @user_paragraphs = UserParagraph.all
  end
  
  def show
    @user_paragraph = UserParagraph.find(params[:id])
  end
  
  def new
    @user_paragraph = UserParagraph.new(:user_article_id => params[:user_article_id])
    @user_article = UserArticle.find(params[:user_article_id])
    @specification_section = @user_article.specification_section
    @client = @specification_section.specification.job.client
    @job = @specification_section.specification.job
    @user_paragraph.user_id = current_user.id
    @user_paragraph = UserParagraph.new(:user_article_id => params[:user_article_id])
  end
  
  def create
    @user_paragraph = UserParagraph.new(params[:user_paragraph])
    
    
    if params[:user_paragraph][:part_article_id] != nil
      part_article = PartArticle.find(params[:user_paragraph][:part_article_id])
      specification_section = part_article.specification_section
    else
      @user_article = @user_paragraph.user_article
      @specification_section = @user_article.specification_section
      @job = @specification_section.specification.job
      user_article = UserArticle.find(params[:user_paragraph][:user_article_id])
      specification_section = user_article.specification_section
    end
    @user_paragraph.user_id = current_user.id
    if @user_paragraph.save
      specification_section.touch
      flash[:notice] = "Successfully created user defined paragraph."
      if params[:user_paragraph][:part_article_id] != nil
        redirect_to new_article_paragraph_path(:part_article_id => part_article.id, :part_id => part_article.part_id, :article_id => part_article.article_id,:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id, :collaborator_id => params[:collaborator_id])
      else
        redirect_to new_user_paragraph_path(:user_article_id => @user_paragraph.user_article_id, :collaborator_id => params[:collaborator_id])
      end
      #redirect_to new_spec_sec_part_path(:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id)
    else
      
      #render :action => 'new'
      if params[:user_paragraph][:part_article_id] != nil
        flash[:error] = "Paragraph can't be blank"
        redirect_to new_article_paragraph_path(:part_article_id => part_article.id, :part_id => part_article.part_id, :article_id => part_article.article_id,:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id, :collaborator_id => params[:collaborator_id])
      else
        
      render :new
      end
    end
  end
  
  def edit
    @user_paragraph = UserParagraph.find(params[:id])
    @user_article = @user_paragraph.user_article
    @specification_section = @user_article.specification_section
    @client = @specification_section.specification.job.client
    @job = @specification_section.specification.job
  end
  
  def update
    @user_paragraph = UserParagraph.find(params[:id])
    @user_article = @user_paragraph.user_article  
    @specification_section = @user_article.specification_section
    @job = @specification_section.specification.job  
    if @user_paragraph.update_attributes(params[:user_paragraph])
      flash[:notice] = "Successfully updated user paragraph."
      redirect_to new_user_paragraph_path(:user_article_id => @user_article.id)
    else
      flash[:warning] = "You need to fill data correctly."
      render :action => 'edit'
    end
  end
  def destroy_part
    @user_paragraph = UserParagraph.find(params[:id])
    @user_paragraph.destroy
    redirect_to new_user_paragraph_path( :user_article_id => @user_paragraph.user_article_id)
  end
  def destroy
    @user_paragraph = UserParagraph.find(params[:id])
    if @user_paragraph.user_article != nil
      specification_section = @user_paragraph.user_article.specification_section
    else
      specification_section = @user_paragraph.part_article.specification_section
    end
    @user_paragraph.destroy
    flash[:notice] = "Paragraph successfully remove."
    redirect_to  new_spec_sec_part_path(:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id)
  end
end
