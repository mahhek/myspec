class StandardArticleParagraphsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager, :except => [:destroy, :update, :create]
       allow logged_in
  end

  def add_master_paragraph
    paragraphs_selected = params[:paragraph]
    unless paragraphs_selected.blank?
      paragraphs_selected.each do |paragraph|
        p = Paragraph.find(paragraph[0])
        article_id = Article.find_by_number_and_part_category(p.article_id, params[:part_id]).id
        pa = StandardPartArticle.find_by_article_id_and_part_id_and_standard_section_id(article_id, params[:part_id], params[:standard_section_id])
        standard_part_article_id = 0
        if pa.blank?
          pa = StandardPartArticle.new
          pa.article_id = article_id
          pa.part_id = params[:part_id]
          pa.standard_section_id = params[:standard_section_id]
          pa.save
        end
        standard_part_article_id = pa.id
        ap = StandardArticleParagraph.new
        ap.paragraph_id = p.id
        ap.standard_part_article_id = standard_part_article_id
        ap.save
      end
    end
    redirect_to "/standard_part_articles/new?part_id=#{params[:part_id]}&standard_section_id=#{params[:standard_section_id]}"
  end
  
  def master_paragraph
    @standard_section = StandardSection.find(params[:standard_section_id])
    @articles = Article.all(:conditions => "part_category = #{params[:part_id]}")
#    @paragraphs = have_paragraph_by_standard_section_id(params[:standard_section_id], params[:part_id])
  end
  
  def have_paragraph_by_standard_section_id(standard_section_id, part_id)

    part_articles = StandardPartArticle.part_id_eq(part_id).standard_section_id_eq(standard_section_id)
    arts = Array.new
    x = 0
    arts[0] = 0
    for a in part_articles
      arts[x] = a.article_id
      x += 1
    end

    barts = Array.new
    x = 0
    barts[0] = 0
    for c in part_articles
      barts[x] = c.id
      x += 1
    end

    article_paragraphs = StandardArticleParagraph.standard_part_article_id_eq(barts)

    ap = Array.new
    x = 0
    ap[0] = 0
    for d in article_paragraphs
      ap[x] = d.paragraph_id
      x += 1
    end


    articles = Article.number_does_not_equal(arts).part_category_eq(part_id)

    parts = Array.new
    x = 0
    parts[0] = 0
    for b in articles
      parts[x] = b.number
      puts b.id
      x += 1
    end


#    paragraphs = Paragraph.article_id_eq(parts).part_id_eq(part_id).id_does_not_equal(ap)
    paragraphs = Paragraph.part_id_eq(part_id).all(:order => "article_id")
    return paragraphs
  end
  
  def index
    @standard_article_paragraphs = StandardArticleParagraph.all
  end
  
  def show
    @standard_article_paragraph = StandardArticleParagraph.find(params[:id])
  end
  
  def new
    #@job = Job.find(params[:job_id])
    @standard_section = StandardSection.find(params[:standard_section_id])
    @standard_part_article = StandardPartArticle.find(params[:standard_part_article_id])
    @have_paragraphs = StandardArticleParagraph.standard_part_article_id_eq(@standard_part_article.id).ascend_by_id
    @paragraphs = have_paragraphs(@standard_part_article.id, @standard_part_article.part_id, @standard_part_article.article.number)
    @standard_article_paragraph = StandardArticleParagraph.new(:standard_part_article_id => params[:standard_part_article_id])
    @standard_user_paragraph = StandardUserParagraph.new(:standard_part_article_id => params[:standard_part_article_id])
  end
  
  def create
    @standard_article_paragraph = StandardArticleParagraph.new(params[:standard_article_paragraph])
    @standard_part_article = StandardPartArticle.find(params[:standard_article_paragraph][:standard_part_article_id])
    standard_section =StandardSection.find(@standard_part_article.standard_section_id)
    paragraphs = have_paragraphs(@standard_part_article.id, @standard_part_article.part_id, @standard_part_article.article.number)
    for paragraph in paragraphs
      if params[:paragraphs][paragraph.id.to_s][:id] == "1"
        StandardArticleParagraph.create(:standard_part_article_id => @standard_part_article.id, :paragraph_id => paragraph.id)
      end
    end
      flash[:notice] = "Standard article paragraph successfully created."
      redirect_to standard_spec_edit_path(:id => standard_section.id)
  end
  
  def have_paragraphs(standard_part_article_id, part_id, article_id)
    article_paragraphs = StandardArticleParagraph.standard_part_article_id_eq(standard_part_article_id)
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
  
  def edit
    @standard_article_paragraph = StandardArticleParagraph.find(params[:id])
  end
  
  def update
    @standard_article_paragraph = StandardArticleParagraph.find(params[:id])
    if @standard_article_paragraph.update_attributes(params[:standard_article_paragraph])
      flash[:notice] = "Successfully updated standard article paragraph."
      redirect_to @standard_article_paragraph
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @standard_article_paragraph = StandardArticleParagraph.find(params[:id])
    standard_section = @standard_article_paragraph.standard_part_article.standard_section
    @standard_article_paragraph.destroy
    flash[:notice] = "Successfully destroyed standard article paragraph."
    redirect_to standard_spec_edit_path(:id => standard_section.id)
  end
end
