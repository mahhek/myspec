class StandardUserSubparagraphsController < ApplicationController
  def index
    @standard_user_subparagraphs = StandardUserSubparagraph.all
  end
  
  def show
    @standard_user_subparagraph = StandardUserSubparagraph.find(params[:id])
  end
  
  def new
    @standard_user_subparagraph = StandardUserSubparagraph.new(:standard_user_paragraph_id => params[:standard_user_paragraph_id])
    @standard_user_paragraph = StandardUserParagraph.find(params[:standard_user_paragraph_id])
    if @standard_user_paragraph.standard_part_article != nil 
      @standard_section = @standard_user_paragraph.standard_part_article.standard_section
    else
      @standard_section = @standard_user_paragraph.standard_user_article.standard_section
    end
    @has_subparagraphs = StandardUserSubparagraph.standard_user_paragraph_id_eq(@standard_user_paragraph.id)
  end
  
  def create
    @standard_user_subparagraph = StandardUserSubparagraph.new(params[:standard_user_subparagraph])
    @standard_user_paragraph = StandardUserParagraph.find(params[:standard_user_subparagraph][:standard_user_paragraph_id])
    if @standard_user_paragraph.standard_part_article != nil 
      @standard_section = @standard_user_paragraph.standard_part_article.standard_section
    else
      @standard_section = @standard_user_paragraph.standard_user_article.standard_section
    end
    @standard_user_subparagraph.user_id = current_user.id
    if @standard_user_subparagraph.save
      flash[:notice] = "Successfully created standard user subparagraph."
      
    else
      flash[:warning] = "Subaragraph cannot be empty."
      #render :action => 'new'
    end
    redirect_to new_standard_user_subparagraph_path(:standard_section_id => @standard_section.id, :standard_user_paragraph_id => @standard_user_paragraph.id)
  end
  
  def edit
    @standard_user_subparagraph = StandardUserSubparagraph.find(params[:id])
    @standard_user_paragraph = @standard_user_subparagraph.standard_user_paragraph
    if @standard_user_paragraph.standard_part_article != nil 
      @standard_section = @standard_user_paragraph.standard_part_article.standard_section
    else
      @standard_section = @standard_user_paragraph.standard_user_article.standard_section
    end
    @has_subparagraphs = StandardUserSubparagraph.standard_user_paragraph_id_eq(@standard_user_paragraph.id)
  end
  
  def update
    @standard_user_subparagraph = StandardUserSubparagraph.find(params[:id])
    @standard_user_paragraph = @standard_user_subparagraph.standard_user_paragraph
    if @standard_user_paragraph.standard_part_article != nil 
      @standard_section = @standard_user_paragraph.standard_part_article.standard_section
    else
      @standard_section = @standard_user_paragraph.standard_user_article.standard_section
    end
    if @standard_user_subparagraph.update_attributes(params[:standard_user_subparagraph])
      flash[:notice] = "Successfully updated standard user subparagraph."
      
    else
      flash[:warning] = "Subaragraph cannot be empty."
      #render :action => 'edit'
    end
    redirect_to new_standard_user_subparagraph_path(:standard_section_id => @standard_section.id, :standard_user_paragraph_id => @standard_user_paragraph.id)
  end
  
  def destroy
    @standard_user_subparagraph = StandardUserSubparagraph.find(params[:id])
    @standard_user_paragraph = @standard_user_subparagraph.standard_user_paragraph
    if @standard_user_paragraph.standard_part_article != nil 
      @standard_section = @standard_user_paragraph.standard_part_article.standard_section
    else
      @standard_section = @standard_user_paragraph.standard_user_article.standard_section
    end
    @standard_user_subparagraph.destroy
    flash[:notice] = "Standard user subparagraph successfully removed."
    redirect_to new_standard_user_subparagraph_path(:standard_section_id => @standard_section.id, :standard_user_paragraph_id => @standard_user_paragraph.id)
  end
end
