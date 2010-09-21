class StandardUserParagraphsController < ApplicationController
  def index
    @standard_user_paragraphs = StandardUserParagraph.all
  end
  
  def show
    @standard_user_paragraph = StandardUserParagraph.find(params[:id])
  end
  
  def new
    @standard_user_paragraph = StandardUserParagraph.new(:standard_user_article_id => params[:standard_user_article_id])
    @standard_user_article = StandardUserArticle.find(params[:standard_user_article_id])
    @standard_section = @standard_user_article.standard_section
  end
  
  def create
    @standard_user_paragraph = StandardUserParagraph.new(params[:standard_user_paragraph])
    if params[:standard_user_paragraph][:standard_part_article_id] != nil
      @standard_part_article = StandardPartArticle.find(params[:standard_user_paragraph][:standard_part_article_id])
      @standard_section = @standard_part_article.standard_section
    else
      @standard_user_article = StandardUserArticle.find(params[:standard_user_paragraph][:standard_user_article_id])
      @standard_section = @standard_user_article.standard_section
    end
    # @have_paragraphs = StandardArticleParagraph.standard_part_article_id_eq(@standard_part_article.id).ascend_by_id
    #     @standard_article_paragraph = StandardArticleParagraph.new(:standard_part_article_id => @standard_part_article.id)
    #     @paragraphs = have_paragraphs(@standard_part_article.id, @standard_part_article.part_id, @standard_part_article.article.number)
    @standard_user_paragraph.user_id = current_user.id
    if @standard_user_paragraph.save
      flash[:notice] = "Successfully created standard user paragraph."
      if params[:standard_user_paragraph][:standard_part_article_id] != nil
        redirect_to new_standard_article_paragraph_path(:article_id => @standard_part_article.article_id, :part_id => @standard_part_article.part_id, :standard_part_article_id => @standard_part_article.id, :standard_section_id => @standard_part_article.standard_section_id)
      else
        redirect_to new_standard_user_paragraph_path(:standard_user_article_id => @standard_user_article.id, :standard_section_id => @standard_section.id)
      end    
      #redirect_to standard_spec_edit_path(:id => standard_section.id)
    else
      flash[:warning] = "Paragraph cannot be empty."
      if params[:standard_user_paragraph][:standard_part_article_id] != nil
        redirect_to new_standard_article_paragraph_path(:article_id => @standard_part_article.article_id, :part_id => @standard_part_article.part_id, :standard_part_article_id => @standard_part_article.id, :standard_section_id => @standard_part_article.standard_section_id)
      else
        redirect_to new_standard_user_paragraph_path(:standard_user_article_id => @standard_user_article.id, :standard_section_id => @standard_section.id)
      end
      #redirect_to new_standard_article_paragraph_path(:standard_section_id => @standard_section.id, :standard_part_article_id => @standard_part_article.id)
      #render '/standard_article_paragraphs/new'
    end
  end
  
  def edit
    @standard_user_paragraph = StandardUserParagraph.find(params[:id])
    if @standard_user_paragraph.standard_part_article != nil
      @standard_part_article = @standard_user_paragraph.standard_part_article
      @standard_section = @standard_part_article.standard_section
    else
      @standard_user_article = @standard_user_paragraph.standard_user_article
      @standard_section = @standard_user_article.standard_section
    end
  end
  
  def update
    @standard_user_paragraph = StandardUserParagraph.find(params[:id])
    if @standard_user_paragraph.standard_part_article != nil
      @standard_part_article = @standard_user_paragraph.standard_part_article
      @standard_section = @standard_part_article.standard_section
    else
      @standard_user_article = @standard_user_paragraph.standard_user_article
      @standard_section = @standard_user_article.standard_section
    end
    if @standard_user_paragraph.update_attributes(params[:standard_user_paragraph])
      flash[:notice] = "Successfully updated standard user paragraph."
        
    else
      flash[:warning] = "Paragraph cannot be empty."
    end
    redirect_to new_standard_user_paragraph_path(:standard_user_article_id => params[:standard_user_paragraph][:standard_user_article_id], :standard_section_id => @standard_section.id)
  end
  
  def destroy
    @standard_user_paragraph = StandardUserParagraph.find(params[:id])
    if @standard_user_paragraph.standard_part_article != nil
      @standard_part_article = @standard_user_paragraph.standard_part_article
      @standard_section = @standard_part_article.standard_section
    else
      @standard_user_article = @standard_user_paragraph.standard_user_article
      @standard_section = @standard_user_article.standard_section
    end
    @standard_user_paragraph.destroy
    flash[:notice] = "Successfully removed standard user paragraph."
     redirect_to new_standard_user_paragraph_path(:standard_user_article_id => @standard_user_article.id, :standard_section_id => @standard_section.id)
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
end
