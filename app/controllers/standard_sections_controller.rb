class StandardSectionsController < ApplicationController
  before_filter :login_required
  
  access_control do
       allow :admin
       allow :manager
  end

  def show_section
    @standard_section = StandardSection.find(params[:id])
    if report_article_number(@standard_section.section.number[0,2]) != "00"
    @standard_section_note = StandardSectionNote.find_by_standard_section_id(params[:id])
    @parts = Part.find(:all)
    end
    @admin_format = AdminFormat.find(User.find(as_user).admin_format.id)
    
  end
  
  def index
     if current_user.parent_id.nil?
      @admins = User.id_or_parent_id_equals(current_user.id)
    else
      @admins = User.id_or_parent_id_equals(current_user.parent.id)
    end

    admin = Array.new
    x = 0
    admin[0] = 0
    for c in @admins
      admin[x] = c.id
      x += 1
    end
    puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    puts admin.inspect
    @standard_sections = StandardSection.user_id_equals(admin).ascend_by_section_id
    @standard_section = StandardSection.new
  end
  
  def search_sections
    number = params[:division_number]
    @sections = Section.number_begins_with(number[0,2]).number_not_begin_with("#{number[0,2]}00")
    render :layout => false
  end
  
  def show
    @standard_section = StandardSection.find(params[:id])
  end
  
  def new
    @job = Job.find(params[:job_id])
    @client = @job.client
    @standard_sections = StandardSection.user_id_equals([current_user.id,as_user])
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @standard_section = StandardSection.new(:job_id => params[:job_id], :specification_section_id => params[:specification_section_id])
  end
  
  def create
    @standard_section = StandardSection.new(params[:standard_section])
    @standard_section.user_id = current_user.id
    @specification_section = SpecificationSection.find(params[:standard_section][:specification_section_id])
    @job = @specification_section.specification.job
    @client = @job.client
    @standard_sections = StandardSection.user_id_equals([current_user.id,as_user])
    @standard_section.section_id = @specification_section.section_id
    if @standard_section.save
      part_articles = PartArticle.find(:all, :conditions => {:specification_section_id => @specification_section.id})
      
      for part_article in part_articles
        #create new part article
        new_part_article = StandardPartArticle.create(:standard_section_id => @standard_section.id, :part_id => part_article.part_id, :article_id => part_article.article_id)
        #get article paragraphs
        article_paragraphs = ArticleParagraph.find(:all, :conditions => {:part_article_id => part_article.id})
        for article_paragraph in article_paragraphs
          #create new article paragraph
          new_article_paragraph = StandardArticleParagraph.create(:standard_part_article_id => new_part_article.id, :paragraph_id => article_paragraph.paragraph_id)
          #get sub paragraph
          subparagraphs = Subparagraph.find(:all, :conditions => {:article_paragraph_id => article_paragraph.id})
          for subparagraph in subparagraphs
            #create new subparagraph
            new_subparagraph = StandardSubparagraph.create(:standard_article_paragraph_id => new_article_paragraph.id, :description => subparagraph.description)
          end
        end
        #user defined
        user_paragraphs = UserParagraph.find(:all, :conditions => {:part_article_id => part_article.id})
        for paragraph in user_paragraphs
          #create new article paragraph
          new_user_paragraph = StandardUserParagraph.create(:standard_part_article_id => new_part_article.id, :name => paragraph.name, :paragraph => paragraph.paragraph, :user_id => paragraph.user_id)
          #get sub paragraph
          subparagraphs = UserSubparagraph.find(:all, :conditions => {:user_paragraph_id => paragraph.id})
          for subparagraph in subparagraphs
            #create new subparagraph
            new_subparagraph = StandardUserSubparagraph.create(:standard_user_paragraph_id => new_user_paragraph.id, :description => subparagraph.description, :user_id => subparagraph.user_id)
          end
        end
      end     
      #from user articles
      user_articles = UserArticle.find(:all, :conditions => {:specification_section_id => specification_section.id})
      for user_article in user_articles
        #create new part article
        new_user_article = StandardUserArticle.create(:standard_section_id => @standard_section.id, :part_id => 1, :name => user_article.name, :user_id => user_article.user_id)
        #user defined
        user_paragraphs = UserParagraph.find(:all, :conditions => {:user_article_id => user_article.id})
        for paragraph in user_paragraphs
          #create new article paragraph
          new_user_paragraph = StandardUserParagraph.create(:standard_user_article_id => new_user_article.id, :paragraph => paragraph.paragraph, :user_id => paragraph.user_id)
          #get sub paragraph
          subparagraphs = UserSubparagraph.find(:all, :conditions => {:user_paragraph_id => paragraph.id})
          for subparagraph in subparagraphs
            #create new subparagraph
            new_subparagraph = StandardUserSubparagraph.create(:standard_user_paragraph_id => new_user_paragraph.id, :description => subparagraph.description, :user_id => subparagraph.user_id)
          end
        end
      end
      flash[:notice] = "Standard section successfully created."
      #redirect_to new_spec_sec_part_path(:job_id => specification_section.specification.job_id, :specification_section_id => specification_section.id)
      redirect_to standard_sections_path
    else 
      if params[:job_id] == nil
        render :action => 'new'
      else
        flash[:warning] = "Standard name cannot be blank."
        redirect_to new_standard_section_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
      end
    end
  end
  
  def create_blank_standard
    @standard_sections = StandardSection.user_id_eq(as_user)
    @standard_section = StandardSection.new(params[:standard_section])
    @standard_section.user_id = current_user.id
    if @standard_section.save
      flash[:notice] = "Standard section successfully created."
      redirect_to standard_sections_path
    else
      render :action => 'index'
    end
  end
  
  def edit
    @standard_section = StandardSection.find(params[:id])
    @standard_sections = StandardSection.user_id_equals([current_user.id,as_user]).ascend_by_section_id
    #@specification_section = SpecificationSection.find(@standard_section.specification_section_id)
  end
  
  def update
    @standard_section = StandardSection.find(params[:id])
    if @standard_section.update_attributes(params[:standard_section])
      flash[:notice] = "Successfully updated standard section."
      redirect_to standard_spec_edit_path(:id => @standard_section.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @standard_section = StandardSection.find(params[:id])
    @standard_section.destroy
    flash[:notice] = "Standard section successfully removed."
    redirect_to standard_sections_url
  end
  
  def spec_edit
    @standard_section = StandardSection.find(params[:id])
    @standard_section_note = StandardSectionNote.new(:standard_section_id => @standard_section.id)
    @parts = Part.find(:all)
    #@specification_section = SpecificationSection.find(@standard_section.specification_section_id)
    #@job = @specification_section.specification.job
    #@section_attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
    @list_general_articles = StandardPartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:standard_section_id => @standard_section.id, :part_id => "1"})
    @list_product_articles = StandardPartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:standard_section_id => @standard_section.id, :part_id => "2"})
    @list_execution_articles = StandardPartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:standard_section_id => @standard_section.id, :part_id => "3"})
  end
end
