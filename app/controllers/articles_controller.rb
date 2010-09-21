class ArticlesController < ApplicationController
  before_filter :login_required
  access_control do
       allow :support
  end
  def index  
    @articles_1 = Article.all(:conditions => "part_category = 1", :order => "number")
    @articles_2 = Article.all(:conditions => "part_category = 2", :order => "number")
    @articles_3 = Article.all(:conditions => "part_category = 3", :order => "number")
  end
  
  def show
    @article = Article.find(params[:id])
  end
  
  def new
    @article = Article.new
  end
  
  def create
    @article = Article.new(params[:article])
    if @article.save
      flash[:notice] = "Successfully created article."
      redirect_to :action => "index"
    else
      render :action => 'new'
    end
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = "Successfully updated article."
      redirect_to :action => "index"
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    flash[:notice] = "Successfully destroyed article."
    redirect_to articles_url
  end
end
