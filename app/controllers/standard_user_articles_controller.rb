class StandardUserArticlesController < ApplicationController
  def index
    @standard_user_articles = StandardUserArticle.all
  end
  
  def show
    @standard_user_article = StandardUserArticle.find(params[:id])
  end
  
  def new
    @standard_user_article = StandardUserArticle.new(:standard_section_id => params[:standard_section_id], :part_id => 1)
    @standard_section = StandardSection.find(params[:standard_section_id])
  end
  
  def create
    @standard_user_article = StandardUserArticle.new(params[:standard_user_article])
    @standard_user_article.user = current_user
    @standard_section = @standard_user_article.standard_section
    if @standard_user_article.save
      flash[:notice] = "Successfully created standard user article."
      redirect_to new_standard_user_article_path(:part_id => 1, :standard_section_id => @standard_user_article.standard_section_id)
      #redirect_to standard_spec_edit_path(:id => @standard_user_article.standard_section_id)
    else
      flash[:warning] = "Article Name cannot be blank."
      redirect_to new_standard_user_article_path(:part_id => 1, :standard_section_id => @standard_user_article.standard_section_id)
      #render :action => 'new'
    end
  end
  
  def edit
    @standard_user_article = StandardUserArticle.find(params[:id])
    @standard_section = @standard_user_article.standard_section
  end
  
  def update
    @standard_user_article = StandardUserArticle.find(params[:id])
    if @standard_user_article.update_attributes(params[:standard_user_article])
      flash[:notice] = "Successfully updated standard user article."
      redirect_to new_standard_user_article_path(:standard_section_id => @standard_user_article.standard_section_id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @standard_user_article = StandardUserArticle.find(params[:id])
    @standard_section = @standard_user_article.standard_section
    @standard_user_article.destroy
    flash[:notice] = "Successfully removed standard user article."
    redirect_to new_standard_user_article_path(:standard_section_id => @standard_section.id)
  end
end
