class StandardPartArticlesController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager, :except => [:destroy, :update, :create]
       allow logged_in
  end
  def index
    @standard_part_articles = StandardPartArticle.all
  end
  
  def show
    @standard_part_article = StandardPartArticle.find(params[:id])
  end
  
  def new
    #@job = Job.find(params[:job_id])
    @part = Part.find(params[:part_id])
    #@specification_section = StandardSection.find(params[:standard_section_id])
    @have_articles = StandardPartArticle.part_id_eq(params[:part_id]).standard_section_id_eq(params[:standard_section_id]).ascend_by_article_id
    @articles = have_articles(params[:part_id], params[:standard_section_id])
    @standard_part_article = StandardPartArticle.new(:part_id => params[:part_id], :standard_section_id => params[:standard_section_id])
  end
  
  def have_articles(part_id, standard_section_id)
    part_articles = StandardPartArticle.part_id_eq(part_id).standard_section_id_eq(standard_section_id)
    arts = Array.new
    x = 0
    arts[0] = 0
    for a in part_articles
      arts[x] = a.article_id
      x += 1
    end
    articles = Article.id_does_not_equal(arts).part_category_eq(part_id)
    return articles
  end
  
  def create
    @standard_part_article = StandardPartArticle.new(params[:standard_part_article])
    standard_section = StandardSection.find(params[:standard_part_article][:standard_section_id])
    articles = have_articles(params[:standard_part_article][:part_id],standard_section.id)
    for article in articles
      if params[:articles][article.id.to_s][:id] == "1"
        StandardPartArticle.create(:standard_section_id => standard_section.id, :part_id => params[:standard_part_article][:part_id], :article_id => article.id)
      end
    end
    flash[:notice] = "Standard part article successfully created."
    redirect_to standard_spec_edit_path(:id => standard_section.id)
  end
  
  def edit
    @standard_part_article = StandardPartArticle.find(params[:id])
  end
  
  def update
    @standard_part_article = StandardPartArticle.find(params[:id])
    if @standard_part_article.update_attributes(params[:standard_part_article])
      flash[:notice] = "Successfully updated standard part article."
      redirect_to @standard_part_article
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @standard_part_article = StandardPartArticle.find(params[:id])
    standard_section = @standard_part_article.standard_section
    @standard_part_article.destroy
    flash[:notice] = "Successfully destroyed standard part article."
    redirect_to standard_spec_edit_path(:id => standard_section.id)
  end
end
