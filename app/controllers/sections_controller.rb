class SectionsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :support
  end
 

  def add_see_section
    section_number = params[:see]
    @section = Section.find_by_number(section_number)
    if @section.blank?
      flash[:notice] = "Invalid Section Number"
    else
      ss = SeeSection.find_by_section_id_and_see_section_id(params[:id], @section.id)
      unless ss.blank?
        flash[:notice] = "Section Already Exists"
      else
        ss = SeeSection.new
        ss.section_id = params[:id]
        ss.see_section_id = @section.id
        ss.save
      end

    end
    redirect_to :action => "edit", :id => params[:id], :div_id => params[:div_id]
  end

  def add_see_also_section
    section_number = params[:see]
    @section = Section.find_by_number(section_number)
    if @section.blank?
      flash[:notice] = "Invalid Section Number"
    else
      ss = SeeAlsoSection.find_by_section_id_and_see_also_section_id(params[:id], @section.id)
      unless ss.blank?
        flash[:notice] = "Section Already Exists"
      else
        ss = SeeAlsoSection.new
        ss.section_id = params[:id]
        ss.see_also_section_id = @section.id
        ss.save
      end

    end
    
    redirect_to :action => "edit", :id => params[:id], :div_id => params[:div_id]
  end

  def delete_see_section
    ss = SeeSection.find(params[:id])
    ss.destroy
    redirect_to :action => "edit", :id => params[:sid], :div_id => params[:div_id]
  end

   def delete_see_also_section
    ss = SeeAlsoSection.find(params[:id])
    ss.destroy
    redirect_to :action => "edit", :id => params[:sid], :div_id => params[:div_id]
  end

  def index
    division = Division.find(params[:id])
    division_number = division.search_number
    @sections = Section.number_begins_with(division_number)
  end
  
  def new
    @section = Section.new
  end
  
  def create
    @section = Section.new(params[:section])
    @section.include = params[:section][:include]
    @section.may_include = params[:section][:may_include]
    @section.usually_include = params[:section][:usually_include]
    @section.does_not_include = params[:section][:does_not_include]
    @section.alternate_terms_abbreviations = params[:section][:alternate_terms_abbreviations]
    @section.notes = params[:section][:notes]
    @section.description = params[:section][:description]
    if @section.save
      flash[:notice] = "Successfully created section."
      redirect_to "/sections?id=#{params[:div_id]}"
    else
      render :action => 'new'
    end
  end
  
  def edit
    @section = Section.find(params[:id])
    @see_sections = @section.see_sections
    @see_also_sections = @section.see_also_sections
  end
  
  def update
    puts params.inspect
    
    @section = Section.find(params[:id])

    if @section.update_attributes(params[:section])
      @section.include = params[:section][:include]
      @section.may_include = params[:section][:may_include]
      @section.usually_include = params[:section][:usually_include]
      @section.does_not_include = params[:section][:does_not_include]
      @section.alternate_terms_abbreviations = params[:section][:alternate_terms_abbreviations]
      @section.notes = params[:section][:notes]
      @section.description = params[:section][:description]
      @section.save
      flash[:notice] = "Successfully updated section."
      redirect_to "/sections?id=#{params[:div_id]}"
    else
      render :action => 'edit'
    end
  end
  def destroy
    @section = Section.find(params[:id])
    @section.destroy
    flash[:notice] = "Section successfully destroyed."
    redirect_to "/sections?id=#{params[:div_id]}"
  end
  
  def list
    @sections = Section.all
    respond_to do |format|
           format.html
           format.xls # add this line to generate xls document
         end
  end
end
