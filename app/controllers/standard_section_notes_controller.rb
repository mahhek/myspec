class StandardSectionNotesController < ApplicationController
  def index
    
    @standard_section = StandardSection.find(params[:standard_section_id])
    @standard_section_notes = StandardSectionNote.standard_section_id_eq(@standard_section.id)
    @standard_section_note = StandardSectionNote.new(:standard_section_id => params[:standard_section_id])
    @section_note = StandardSectionNote.find_by_standard_section_id(@standard_section.id)
    if params[:mode] == "1" && params[:type] == "a"
      @spa = StandardPartArticle.find(params[:sid])
    elsif params[:mode] == "1" && params[:type] == "p"
      @sap = StandardArticleParagraph.find(params[:sid])
    elsif params[:mode] == "1" && params[:type] == "s"
      @ssp = StandardSubparagraph.find(params[:sid])
    end
    @standard_section_articles = StandardPartArticle.find_all_by_standard_section_id(@standard_section.id)
  end

  def delete_note
    if params[:type] == "g"
      ssn = StandardSectionNote.find_by_standard_section_id(params[:id])
      ssn.description = ""
      ssn.save
      standard_section_id = params[:id]
    elsif params[:type] == "a"
      spa = StandardPartArticle.find(params[:id])
      spa.note = ""
      spa.save
      standard_section_id = spa.standard_section_id
    elsif params[:type] == "p"
      sap = StandardArticleParagraph.find(params[:id])
      sap.note = ""
      sap.save
      standard_section_id = sap.standard_part_article.standard_section_id
    elsif params[:type] == "s"
      ssp = StandardSubparagraph.find(params[:id])
      ssp.note = ""
      ssp.save
      standard_section_id = ssp.standard_article_paragraph.standard_part_article.standard_section_id
    end
    
    redirect_to :action => 'index', :standard_section_id => standard_section_id

  end
  
  def show
    @standard_section_note = StandardSectionNote.find(params[:id])
  end
  
  def new
    @standard_section_note = StandardSectionNote.new(:standard_section_id => params[:standard_section_id])
  end
  
  def create
    
    standard_section_id = params[:standard_section_note][:standard_section_id]    
    notes = params[:note]
    if params[:type] == "g" || params[:mode].blank?
      @standard_section_note = StandardSectionNote.find_by_standard_section_id(standard_section_id)
      if @standard_section_note.blank?
        @standard_section_note = StandardSectionNote.new(params[:standard_section_note])
        @standard_section_note.user = current_user
      end
      @standard_section_note.description = notes
      
      if @standard_section_note.save
        flash[:notice] = "Successfully created standard section note."
        redirect_to standard_section_notes_path(:standard_section_id => standard_section_id)
        #redirect_to standard_spec_edit_path(:id => @standard_section_note.standard_section.id)
      else
        @standard_section = StandardSection.find(standard_section_id)
        redirect_to :action => 'index', :standard_section_id => standard_section_id
      end    
    elsif params[:type] == "a"
      standard_part_article_id = params[:sid]
      spa = StandardPartArticle.find(standard_part_article_id)
      spa.note = notes
      if spa.save
        flash[:notice] = "Successfully created standard section note for article."
        redirect_to standard_section_notes_path(:standard_section_id => standard_section_id)
      else
        @standard_section = StandardSection.find(standard_section_id)
        redirect_to :action => 'index', :standard_section_id => standard_section_id
      end
    elsif params[:type] == "p"
      standard_article_paragraph_id = params[:sid]
      sap = StandardArticleParagraph.find(standard_article_paragraph_id)
      sap.note = notes
      if sap.save
        flash[:notice] = "Successfully created standard section note for paragraph."
        redirect_to standard_section_notes_path(:standard_section_id => standard_section_id)
      else
        @standard_section = StandardSection.find(standard_section_id)
        redirect_to :action => 'index', :standard_section_id => standard_section_id
      end
    elsif params[:type] == "s"
      sub_id = params[:sid]
      ss = StandardSubparagraph.find(sub_id)
      ss.note = notes
      if ss.save
        flash[:notice] = "Successfully created standard section note for subparagraph."
        redirect_to standard_section_notes_path(:standard_section_id => standard_section_id)
      else
        @standard_section = StandardSection.find(standard_section_id)
        redirect_to :action => 'index', :standard_section_id => standard_section_id
      end
    end
       
  end
  
  def edit
    @standard_section_note = StandardSectionNote.find(params[:id])
    @standard_section = @standard_section_note.standard_section
  end
  
  def update
    @standard_section_note = StandardSectionNote.find(params[:id])
    @standard_section = @standard_section_note.standard_section
    if @standard_section_note.update_attributes(params[:standard_section_note])
      flash[:notice] = "Successfully updated standard section note."
      redirect_to standard_section_notes_path(:standard_section_id => @standard_section.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @standard_section_note = StandardSectionNote.find(params[:id])
    @standard_section = @standard_section_note.standard_section
    @standard_section_note.destroy
    flash[:notice] = "Successfully removed standard section note."
    redirect_to standard_section_notes_path(:standard_section_id => @standard_section.id)
    #redirect_to standard_spec_edit_path(:id => @standard_section.id)
  end
  
  def part_change
    @standard_part_articles = StandardPartArticle.part_id_eq(params[:part_id]).standard_section_id_eq(params[:standard_section_id])
    render :layout => false
  end
  
  def article_change
    @standard_article_paragraphs = StandardArticleParagraph.standard_part_article_id_eq(params[:part_article_id])
    render :layout => false
  end
  
  def paragraph_change
    @standard_subparagraphs = StandardSubparagraph.standard_article_paragraph_id_eq(params[:article_paragraph_id]).ascend_by_id
    render :layout => false
  end
end
