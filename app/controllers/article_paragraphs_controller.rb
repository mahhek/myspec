class ArticleParagraphsController < ApplicationController
  before_filter :login_required
  access_control do
    allow :admin
    allow :manager
    allow logged_in
  end
  def show_article_description
    @article = Article.find(params[:id])
      render :update do |page|
      @article.description = @article.description.gsub(/\r\n/, "<br/>")
      @article.description = @article.description.gsub(/\r/, "<br/>")
      @article.description = @article.description.gsub(/\n/, "<br/>")
      @article.description = @article.description.gsub(/"/, "'")
      page << 'Modalbox.show(("<div>'+@article.description+'</div>"), {title: "'+@article.name+'", height: 250, width:550});'
    end
  end
  def show_paragraph_descritpion
    @paragraph = Paragraph.find(params[:id])
    render :update do |page|
      @paragraph.description = @paragraph.description.gsub(/\r\n/, "<br/>")
      @paragraph.description = @paragraph.description.gsub(/\r/, "<br/>")
      @paragraph.description = @paragraph.description.gsub(/\n/, "<br/>")
      @paragraph.description = @paragraph.description.gsub(/"/, "'")
      page << 'Modalbox.show(("<div>'+@paragraph.description+'</div>"), {title: "'+@paragraph.name+'", height: 250, width:550});'
    end
  end

  def master_paragraph
    @job = Job.find(params[:job_id])
    @client = @job.client
    @articles = Article.all(:conditions => "part_category = #{params[:part_id]}")
#    @paragraphs = have_paragraph_by_specification_section_id(params[:specification_section_id], params[:part_id])
  end

  def add_master_paragraph    
    paragraphs_selected = params[:paragraph]
    unless paragraphs_selected.blank?
      paragraphs_selected.each do |paragraph|
        p = Paragraph.find(paragraph[0])
        article_id = Article.find_by_number_and_part_category(p.article_id, params[:part_id]).id
        pa = PartArticle.find_by_article_id_and_part_id_and_specification_section_id(article_id, params[:part_id], params[:specification_section_id])
        part_article_id = 0
        if pa.blank?
          pa = PartArticle.new
          pa.article_id = article_id
          pa.part_id = params[:part_id]
          pa.specification_section_id = params[:specification_section_id]
          pa.save
        end
        part_article_id = pa.id
        ap = ArticleParagraph.new
        ap.paragraph_id = p.id
        ap.part_article_id = part_article_id
        ap.save
      end
    end
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @specification_section.touch
    redirect_to "/part_articles/new?job_id=#{params[:job_id]}&specification_section_id=#{params[:specification_section_id]}&part_id=#{params[:part_id]}"
  end
  
  def new
    @job = Job.find(params[:job_id])
    @client = @job.client
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @part_article = PartArticle.find(params[:part_article_id])
    
    #@paragraphs = Paragraph.part_id_eq(params[:part_id]).article_id_eq(params[:article_id])
    @have_paragraphs = ArticleParagraph.part_article_id_eq(@part_article.id).ascend_by_id
    @paragraphs = have_paragraphs(@part_article.id, @part_article.part_id, @part_article.article.number)
    @article_paragraph = ArticleParagraph.new(:part_article_id => params[:part_article_id])
    @user_paragraph = UserParagraph.new(:part_article_id => params[:part_article_id])
  end
  
  def create
    @article_paragraph = ArticleParagraph.new(params[:article_paragraph])
    @part_article = PartArticle.find(params[:article_paragraph][:part_article_id])
    specification_section = SpecificationSection.find(@part_article.specification_section_id)
    job_id = @article_paragraph.part_article.specification_section.specification.job_id
    paragraphs = have_paragraphs(@part_article.id, @part_article.part_id, @part_article.article.number)
    for paragraph in paragraphs
      if params[:paragraphs][paragraph.id.to_s][:id] == "1"
        ArticleParagraph.create(:part_article_id => @part_article.id, :paragraph_id => paragraph.id)
      end
    end
    flash[:notice] = "Paragraphs successfully added."
    specification_section.touch
    redirect_to new_article_paragraph_path(:part_article_id => @part_article.id, :part_id => @part_article.part_id, :article_id => @part_article.article_id,:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id, :collaborator_id => params[:collaborator_id])
    #redirect_to new_spec_sec_part_path(:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id, :collaborator_id => params[:collaborator_id])
  end
  
  def have_paragraphs(part_article_id, part_id, article_id)
    article_paragraphs = ArticleParagraph.part_article_id_eq(part_article_id)
    pars = Array.new
    x = 0
    pars[0] = 0
    for a in article_paragraphs
      pars[x] = a.paragraph_id
      x += 1
    end
    paragraphs = Paragraph.id_does_not_equal(pars).part_id_eq(part_id).article_id_eq(article_id)
    return paragraphs
  end

  
  def have_paragraph_by_specification_section_id(part_id, article_id)

#    part_articles = PartArticle.part_id_eq(part_id).specification_section_id_eq(specification_section_id)
#    arts = Array.new
#    x = 0
#    arts[0] = 0
#    for a in part_articles
#      arts[x] = a.article_id
#      x += 1
#    end
#
#    barts = Array.new
#    x = 0
#    barts[0] = 0
#    for c in part_articles
#      barts[x] = c.id
#      x += 1
#    end
#
#    article_paragraphs = ArticleParagraph.part_article_id_eq(barts)
#
#    ap = Array.new
#    x = 0
#    ap[0] = 0
#    for d in article_paragraphs
#      ap[x] = d.paragraph_id
#      x += 1
#    end
#
#
#    articles = Article.number_does_not_equal(arts).part_category_eq(part_id)
#
#    parts = Array.new
#    x = 0
#    parts[0] = 0
#    for b in articles
#      parts[x] = b.number
#      puts b.id
#      x += 1
#    end

    
#    paragraphs = Paragraph.article_id_eq(parts).part_id_eq(part_id).id_does_not_equal(ap)
    paragraphs = Paragraph.part_id_eq(part_id).article_id_eq(article_id).all(:order => "article_id")
    return paragraphs
  end
  
  def destroy
    @article_paragraph = ArticleParagraph.find(params[:id])
    specification_section = @article_paragraph.part_article.specification_section
    job_id = @article_paragraph.part_article.specification_section.specification.job_id
    @article_paragraph.destroy
    flash[:notice] = "Paragraph successfully removed."
    specification_section.touch
    redirect_to new_spec_sec_part_path(:job_id => job_id, :specification_section_id => specification_section.id, :collaborator_id => params[:collaborator_id])
  end
end
