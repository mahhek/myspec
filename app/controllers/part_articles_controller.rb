class PartArticlesController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       allow :team
  end
  def index
    @part_articles = PartArticle.all
  end
  
  def show
    @part_article = PartArticle.find(params[:id])
  end
  
  def new
    @job = Job.find(params[:job_id])
    @client = @job.client
    @part = Part.find(params[:part_id])
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @have_articles = PartArticle.part_id_eq(params[:part_id]).specification_section_id_eq(params[:specification_section_id]).ascend_by_article_id
    @articles = have_articles(params[:part_id], params[:specification_section_id])
    @part_article = PartArticle.new(:part_id => params[:part_id], :specification_section_id => params[:specification_section_id])
  end
  
  #create multiple articles
  def create
    @part_article = PartArticle.new(params[:part_article])
    specification_section = SpecificationSection.find(params[:part_article][:specification_section_id])
    articles = have_articles(params[:part_article][:part_id],specification_section.id)
    for article in articles
      if params[:articles][article.id.to_s][:id] == "1"
        PartArticle.create(:specification_section_id => specification_section.id, :part_id => params[:part_article][:part_id], :article_id => article.id)
      end
    end
    flash[:notice] = "Articles successfully added."
    specification_section.touch
    redirect_to new_spec_sec_part_path(:job_id => specification_section.specification.job_id, :specification_section_id => specification_section, :collaborator_id => params[:collaborator_id])
  end
  
  def have_articles(part_id, specification_section_id)
    part_articles = PartArticle.part_id_eq(part_id).specification_section_id_eq(specification_section_id)
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
  
  def edit
    @part_article = PartArticle.find(params[:id])
  end
  
  def update
    @part_article = PartArticle.find(params[:id])
    if @part_article.update_attributes(params[:part_article])
      flash[:notice] = "Successfully updated part article."
      @specification_section.touch
      redirect_to @part_article
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @part_article = PartArticle.find(params[:id])
    @specification_section = SpecificationSection.find(@part_article.specification_section_id)
    @part_article.destroy
    @specification_section.touch
    flash[:notice] = "Article successfully removed."
    redirect_to new_spec_sec_part_path(:job_id => @specification_section.specification.job_id, :specification_section_id => @specification_section, :collaborator_id => params[:collaborator_id])
  end
end
