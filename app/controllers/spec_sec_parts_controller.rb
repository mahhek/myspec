class SpecSecPartsController < ApplicationController
  before_filter :login_required
  access_control do
    allow :admin
    allow :manager
    allow :team
  end

  def change_section
    
    standard_section_id = params[:standard_section_id]
    @description = StandardSection.find(standard_section_id).comments
    render :update do |page|
     page.replace_html 'section_div', :partial => "description"
    end
  end

  def show_related_sections
    @section = Section.find(params[:id])
    render :update do |page|
      unless @section.include.blank?
      @section.include = @section.include.gsub(/\r\n/, "<br/>")
      @section.include = @section.include.gsub(/\r/, "<br/>")
      @section.include = @section.include.gsub(/\n/, "<br/>")
      @section.include = @section.include.gsub(/"/, "'")
      else
        @section.include = ""
      end
      unless @section.may_include.blank?
      @section.may_include = @section.may_include.gsub(/\r\n/, "<br/>")
      @section.may_include = @section.may_include.gsub(/\r/, "<br/>")
      @section.may_include = @section.may_include.gsub(/\n/, "<br/>")
      @section.may_include = @section.may_include.gsub(/"/, "'")
      else
        @section.may_include = ""
      end
      
      unless @section.usually_include.blank?
      @section.usually_include = @section.usually_include.gsub(/\r\n/, "<br/>")
      @section.usually_include = @section.usually_include.gsub(/\r/, "<br/>")
      @section.usually_include = @section.usually_include.gsub(/\n/, "<br/>")
      @section.usually_include = @section.usually_include.gsub(/"/, "'")
      else
        @section.usually_include = ""
      end

      unless @section.does_not_include.blank?
      @section.does_not_include = @section.does_not_include.gsub(/\r\n/, "<br/>")
      @section.does_not_include = @section.does_not_include.gsub(/\r/, "<br/>")
      @section.does_not_include = @section.does_not_include.gsub(/\n/, "<br/>")
      @section.does_not_include = @section.does_not_include.gsub(/"/, "'")
      else
        @section.does_not_include = ""
      end
      unless @section.alternate_terms_abbreviations.blank?
      @section.alternate_terms_abbreviations = @section.alternate_terms_abbreviations.gsub(/\r\n/, "<br/>")
      @section.alternate_terms_abbreviations = @section.alternate_terms_abbreviations.gsub(/\r/, "<br/>")
      @section.alternate_terms_abbreviations = @section.alternate_terms_abbreviations.gsub(/\n/, "<br/>")
      @section.alternate_terms_abbreviations = @section.alternate_terms_abbreviations.gsub(/"/, "'")
      else
        @section.alternate_terms_abbreviations = ""
      end
      
      see = "<ul>"
      seesections = SeeSection.find_all_by_section_id(@section.id)

      unless seesections.blank?
        seesections.each do |seesection|
          section = Section.find(seesection.see_section_id)
          see += "<li>" + section.modif_number + " - " + section.name + "</li>"
        end
      end
      see += "</ul>"

      see_also = "<ul>"
      seesections = SeeAlsoSection.find_all_by_section_id(@section.id)

      unless seesections.blank?
        seesections.each do |seesection|
          section = Section.find(seesection.see_also_section_id)
          see_also += "<li>" + section.modif_number + " - " + section.name + "</li>"
        end
      end
      see_also += "</ul>"
      
      page << 'Modalbox.show(("<div> <b>Include: </b>'+@section.include+'<br/><b>May Include: </b>'+@section.may_include+'<br/><b>Usually Include: </b>'+@section.usually_include+'<br/><b>Does not Include: </b>'+@section.does_not_include+'<br/> <b>Alternate Terms/Abbreviations: </b>'+@section.alternate_terms_abbreviations+'<br/><b>See:</b>'+see+'<b>See Also:</b>'+see_also+'</div>"), {title: "'+@section.modif_number  + ' - ' + @section.name+'", height: 270, width:600});'
    end
  end
  
  def shared_section_editor
    @parts = Part.find(:all)
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @job = @specification_section.specification.job
    @client = @job.client
    @section_attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
    @list_general_articles = PartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:specification_section_id => @specification_section, :part_id => "1"})
    @list_product_articles = PartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:specification_section_id => @specification_section, :part_id => "2"})
    @list_execution_articles = PartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:specification_section_id => @specification_section, :part_id => "3"})
    @spec_sec_part = SpecSecPart.new(:specification_section_id => params[:specification_section_id])
    
    @already_have_1 = Array.new
    if @list_general_articles.size > 0
      x = 0
      for a in @list_general_articles
        @already_have_1[x] = a.article_id
        x = x + 1
      end
    else
      @already_have_1[0] = 0
    end
    
    @already_have_2 = Array.new
    if @list_product_articles.size > 0
      x = 0
      for a in @list_product_articles
        @already_have_2[x] = a.article_id
        x = x + 1
      end
    else
      @already_have_2[0] = 0
    end
    
    @already_have_3 = Array.new
    if @list_execution_articles.size > 0
      x = 0
      for a in @list_execution_articles
        @already_have_3[x] = a.article_id
        x = x + 1
      end
    else
      @already_have_3[0] = 0
    end
    
    
    @part_article = PartArticle.new(:part_id => params[:part_id], :specification_section_id => params[:specification_section_id])
    
    @articles_1 = Article.part_category_eq(1).id_does_not_equal(@already_have_1)
    
    @articles_2 = Article.part_category_eq(2).id_does_not_equal(@already_have_2)
    @articles_3 = Article.part_category_eq(3).id_does_not_equal(@already_have_3)
  end

  def new
    
    @parts = Part.find(:all)
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @standard_sections = StandardSection.section_id_eq(@specification_section.section_id).user_id_eq([as_user, current_user.id])
    @job = @specification_section.specification.job
    @client = @job.client
    @section_attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
    @list_general_articles = PartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:specification_section_id => @specification_section, :part_id => "1"})
    @list_product_articles = PartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:specification_section_id => @specification_section, :part_id => "2"})
    @list_execution_articles = PartArticle.find(:all, :include => [:article], :order => "articles.id ASC", :conditions => {:specification_section_id => @specification_section, :part_id => "3"})
    @spec_sec_part = SpecSecPart.new(:specification_section_id => params[:specification_section_id])
    
    @already_have_1 = Array.new
    if @list_general_articles.size > 0
      x = 0
      for a in @list_general_articles
        @already_have_1[x] = a.article_id
        x = x + 1
      end
    else
      @already_have_1[0] = 0
    end
    
    @already_have_2 = Array.new
    if @list_product_articles.size > 0
      x = 0
      for a in @list_product_articles
        @already_have_2[x] = a.article_id
        x = x + 1
      end
    else
      @already_have_2[0] = 0
    end
    
    @already_have_3 = Array.new
    if @list_execution_articles.size > 0
      x = 0
      for a in @list_execution_articles
        @already_have_3[x] = a.article_id
        x = x + 1
      end
    else
      @already_have_3[0] = 0
    end
    
    
    @part_article = PartArticle.new(:part_id => params[:part_id], :specification_section_id => params[:specification_section_id])
    
    @articles_1 = Article.part_category_eq(1).id_does_not_equal(@already_have_1)
    
    @articles_2 = Article.part_category_eq(2).id_does_not_equal(@already_have_2)
    @articles_3 = Article.part_category_eq(3).id_does_not_equal(@already_have_3)
    respond_to do |format|
      format.html
      format.pdf {
        dir = RAILS_ROOT + "/tmp/pdfs/sections/"+@specification_section.id.to_s
        FileUtils.mkdir_p(dir)
        pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
        if report_article_number(@specification_section.specification.division.short_number) != "00"
        if @job.layout_id.blank? || @job.layout_id == 1 || @job.layout_id == 3
          pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
          pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(5)
          pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)
          for part in @parts
            parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
            pdf.table parts, :font_size => 9, :style => :bold,
            :column_widths => {0 => 380},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            pdf.move_down(5)
            if part.id == 1
              a = 1
              for article in @list_general_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
                pdf.table articles, :font_size => 9,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                for paragraph in article.article_paragraphs
                  paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
                  pdf.table paragraphs, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 35, 1 => 20, 2 => 380},
                  :position => :left,
                  :vertical_padding => 1,
                  :border_width   => 0,
                  :align => {2 => :left}
                  pdf.move_down(5)
                  c = 1
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["","#{c}.",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 55, 1 => 25, 2 => 380},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 2
              a = 1
              for article in @list_product_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                              
                b = 97
                for paragraph in article.article_paragraphs
                  paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
                  pdf.table paragraphs, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 35, 1 => 20, 2 => 380},
                  :position => :left,
                  :vertical_padding => 1,
                  :border_width       => 0
                  pdf.move_down(5)
                  c = 1
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["","#{c}.",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 55, 1 => 25, 2 => 380},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 3
              a = 1
              for article in @list_execution_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                for paragraph in article.article_paragraphs
                  paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
                  pdf.table paragraphs, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 35, 1 => 20, 2 => 380},
                  :position => :left,
                  :vertical_padding => 1,
                  :border_width       => 0
                  pdf.move_down(5)
                  c = 1
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["","#{c}.",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 55, 1 => 25, 2 => 380},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            end
            pdf.move_down(10)
          end
          attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)
          
          attach = [[{:text => "ATTACHMENTS", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 30, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                
              ind = ind + 1
          end

          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
      end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
                 
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw
              
          end          
          elsif @job.layout_id == 2
            pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

          pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(5)
          pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)

          for part in @parts
            parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
            pdf.table parts, :font_size => 9, :style => :bold,
            :column_widths => {0 => 380},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            pdf.move_down(5)
            if part.id == 1
              a = 1
              for article in @list_general_articles
                articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 1

                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                        subparagraphs = [["#{part.id}.#{a}.#{b}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                        subparagraphs = [["#{part.id}.#{a}.#{b}",subparagraph.description]]
                    end
                    
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 40, 1 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                  b += 1
                  end

                end
                a += 1
              end
            elsif part.id == 2
              a = 1
              for article in @list_product_articles
               articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 1

                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                        subparagraphs = [["#{part.id}.#{a}.#{b}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                        subparagraphs = [["#{part.id}.#{a}.#{b}",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 40, 1 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                  b += 1
                  end

                end
                a += 1
              end
            elsif part.id == 3
              a = 1
              for article in @list_execution_articles
                articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 40, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 1
               
                for paragraph in article.article_paragraphs
                  d  = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                        subparagraphs = [["#{part.id}.#{a}.#{b}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                        subparagraphs = [["#{part.id}.#{a}.#{b}",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 40, 1 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                  b += 1
                  end
                  
                end
                a += 1
              end
            end
            pdf.move_down(10)
          end
          attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)

          attach = [[{:text => "ATTACHMENTS", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 30, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width => 0
              ind = ind + 1
          end

          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
      end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw

          end
        elsif @job.layout_id == 4
          pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
          pdf.text "#{@specification_section.section.report_number} - #{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)
          for part in @parts
            parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
            pdf.table parts, :font_size => 9, :style => :bold,
            :column_widths => {0 => 380},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            pdf.move_down(5)

              if part.id == 2
                 @list_general_articles = @list_product_articles
              elsif part.id == 3
                 @list_general_articles  = @list_execution_articles
              end
             
              for article in @list_general_articles
                articles = [[{:text => article.article.name.upcase, :font_style => :bold}]]
                pdf.table articles, :font_size => 9,
                :column_widths => {0 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
             
                for paragraph in article.article_paragraphs
                 
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 40, 1 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                 
                  end
                 
                end
                
              end
            
            
            pdf.move_down(10)
          end
          attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)

          attach = [[{:text => "ATTACHMENTS", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 30, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

              ind = ind + 1
          end

          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
      end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw

        end
        elsif @job.layout_id == 5
           pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

          pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(5)
          pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)

          for part in @parts
            parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
            pdf.table parts, :font_size => 9, :style => :bold,
            :column_widths => {0 => 380},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            pdf.move_down(5)
            if part.id == 1
              a = 1
              for article in @list_general_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                        subparagraphs = [["","#{c}.","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                       subparagraphs = [["","#{c}.",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 35, 1 => 25, 2 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 2
              a = 1
              for article in @list_product_articles
               articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                      d = d + 1
                        subparagraphs = [["","#{c}.","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                       subparagraphs = [["","#{c}.",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 35, 1 => 25, 2 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 3
              a = 1
              for article in @list_execution_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                        d = d + 1
                        subparagraphs = [["","#{c}.","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                       subparagraphs = [["","#{c}.",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 35, 1 => 25, 2 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            end
            pdf.move_down(10)
          end
          attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)

          attach = [[{:text => "ATTACHMENTS", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 30, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

              ind = ind + 1
          end

          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
      end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw

          end
          elsif @job.layout_id == 6
            pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

          pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(5)
          pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)

          for part in @parts
            parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
            pdf.table parts, :font_size => 9, :style => :bold,
            :column_widths => {0 => 380},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            pdf.move_down(5)
            if part.id == 1
              a = 1
              for article in @list_general_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
                pdf.table articles, :font_size => 9,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 1
                for paragraph in article.article_paragraphs
                  paragraphs = [["",".#{b}",paragraph.paragraph.name]]
                  pdf.table paragraphs, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 35, 1 => 25, 2 => 380},
                  :position => :left,
                  :vertical_padding => 1,
                  :border_width   => 0,
                  :align => {2 => :left}
                  pdf.move_down(5)
                  c = 1
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["",".#{c}",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 60, 1 => 25, 2 => 375},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 2
              a = 1
              for article in @list_product_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)

                b = 1
                for paragraph in article.article_paragraphs
                  paragraphs = [["",".#{b}",paragraph.paragraph.name]]
                  pdf.table paragraphs, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 35, 1 => 25, 2 => 380},
                  :position => :left,
                  :vertical_padding => 1,
                  :border_width       => 0
                  pdf.move_down(5)
                  c = 1
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["",".#{c}",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 60, 1 => 25, 2 => 375},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 3
              a = 1
              for article in @list_execution_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 1
                for paragraph in article.article_paragraphs
                  paragraphs = [["",".#{b}",paragraph.paragraph.name]]
                  pdf.table paragraphs, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 35, 1 => 25, 2 => 380},
                  :position => :left,
                  :vertical_padding => 1,
                  :border_width       => 0
                  pdf.move_down(5)
                  c = 1
                  for subparagraph in paragraph.subparagraphs
                    subparagraphs = [["",".#{c}",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 60, 1 => 25, 2 => 375},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            end
            pdf.move_down(10)
          end
          attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)

          attach = [[{:text => "ATTACHMENTS", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 30, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

              ind = ind + 1
          end

          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
      end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw

          end 
          elsif @job.layout_id == 7
           pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

          pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(5)
          pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)

          for part in @parts
            parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
            pdf.table parts, :font_size => 9, :style => :bold,
            :column_widths => {0 => 380},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            pdf.move_down(5)
            if part.id == 1
              a = 1
              for article in @list_general_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                        subparagraphs = [["",".#{c}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                        subparagraphs = [["",".#{c}",subparagraph.description]]
                    end
                    
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 35, 1 => 25, 2 => 400},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 2
              a = 1
              for article in @list_product_articles
               articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                       subparagraphs = [["",".#{c}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                       subparagraphs = [["",".#{c}",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 35, 1 => 25, 2 => 400},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            elsif part.id == 3
              a = 1
              for article in @list_execution_articles
                articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 35, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.article_paragraphs
                  d = 1
                  for subparagraph in paragraph.subparagraphs
                    if d == 1
                       d = d + 1
                        subparagraphs = [["",".#{c}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                    else
                        subparagraphs = [["",".#{c}",subparagraph.description]]
                    end
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 35, 1 => 25, 2 => 400},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                    c += 1
                  end
                  b += 1
                end
                a += 1
              end
            end
            pdf.move_down(10)
          end
          attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)

          attach = [[{:text => "ATTACHMENTS", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 30, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

              ind = ind + 1
          end

          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
      end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw

          end          
        end

          
        else
          
          pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
            
            main = [[{:text => "#{@specification_section.section.report_number}  #{@specification_section.section.name.upcase}", :font_style => :bold}]]
            pdf.table main, :font_size => 9, :style => :bold,
                :column_widths => {0 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
 
              pdf.move_down(5)
          

          pdf.move_down(10)
              @articles = UserArticle.find_all_by_specification_section_id(@specification_section.id)
              unless @articles.blank?
              main = [[{:text => "Table of Articles", :font_style => :bold}]]
              pdf.table main, :font_size => 9, :style => :bold,
                :column_widths => {0 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                a = 1
                for article in @articles
                  articles = [["#{a}.",article.name]]
                  pdf.table articles, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 20, 1 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0
                  a = a + 1
                end
              
              end
                  attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
          if attachments.size > 0
          pdf.move_down(10)

          attach = [[{:text => "Attachments", :font_style => :bold}]]
          pdf.table attach, :font_size => 9, :style => :bold,
                :column_widths => {0 => 200},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

            ind = 1
          end
          for attachment in attachments
            attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
            pdf.table attach, :font_size => 9,
                :column_widths => {0 => 20, 1 => 380},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0

              ind = ind + 1
          end
              
            pdf.move_down(20)
            unless @articles.blank?
             for article in @articles
                 pdf.move_down(5)
                articles = [[{:text => article.name, :font_style => :bold}]]
                pdf.table articles, :font_size => 9, :style => :bold,
                :column_widths => {0 => 460},
                :position => :left,
                :vertical_padding => 2,
                :border_width       => 0
                pdf.move_down(5)
                b = 97
                c = 1
                for paragraph in article.user_paragraphs
                paragraphs = [["#{b.chr.upcase}.", paragraph.paragraph]]
                pdf.table paragraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 20, 1 => 440},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                    pdf.move_down(5)
                  for subparagraph in paragraph.user_subparagraphs
                    subparagraphs = [["","#{c}.",subparagraph.description]]
                    pdf.table subparagraphs, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 20, 1 => 20, 2 => 420},
                    :inline_format => true,
                    :position => :left,
                    :vertical_padding => 1,
                    :border_width       => 0,
                    :align => {2 => :left}
                  
                    c += 1
                  end
                  b += 1
                end
             
              end
          end
            
            pdf.move_down(10)
          
              
          end
          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
              }.draw

          end
        end
        File.open(dir + "/"+ @specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }
        #connect to cloud files
        @ccf = CloudFiles::Connection.new(CLOUD_CONFIG['username'],CLOUD_CONFIG['api_key'])
        container = @ccf.container(CLOUD_CONFIG['container'])
        
        @attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
        #get all attachments
        i = 1
        for attachment in @attachments
          object = container.object(attachment.asset.path)
          tmp = File.open(dir + "/"+attachment.specification_section.section.number.to_s+"-"+i.to_s+".pdf", "w+")
          tmp.syswrite(object.data)
          i += 1
        end
        @processes = `zip "tmp/pdfs/sections/#{@specification_section.id.to_s}.zip" tmp/pdfs/sections/#{@specification_section.id.to_s}/*`
        send_file(RAILS_ROOT + "/tmp/pdfs/sections/"+@specification_section.id.to_s+".zip", :type => "application/zip", :filename => @job.number.to_s+".zip" )
      }
    end
  end
  
  
  
  def add_article
    @part_article = PartArticle.new(:part_id => params[:part_id], :article_id => params[:article_id])
  end
  
  def create_article
    @part_article = PartArticle.new(params[:part_article])
  end
  
  def part_editor
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @job = @specification_section.specification.job
    @part = Part.find(params[:part_id])
  end
  
  def create_part
    @specification_section = SpecificationSection.find(params[:specification_section][:id])
    @job = @specification_section.specification.job
    if @specification_section.update_attributes(params[:specification_section])
      for part_article in @specification_section.part_articles
        part_article.part_id = params[:part_id]
        part_article.save
      end
      flash[:notice] = "Successfully updated part 1."
      redirect_to new_spec_sec_part_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
    else
      render :action => part_editor_path(:part_id => params[:part_id])
    end
  end
  
  def import_section
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @job = @specification_section.specification.job
    @client = @job.client
    @standard_sections = StandardSection.section_id_eq(@specification_section.section_id).user_id_eq([as_user, current_user.id])
  end
  
  def create_section
    @standard_section = StandardSection.find(params[:standard_section][:id])
    @specification_section = SpecificationSection.find(params[:spec_sec_part][:specification_section_id])
    part_articles = StandardPartArticle.find(:all, :conditions => {:standard_section_id => @standard_section.id})
    
    #part_articles = PartArticle.find(:all, :conditions => {:specification_section_id => specification_section.id})
    for part_article in part_articles
      #create new part article
      new_part_article = PartArticle.create(:specification_section_id => @specification_section.id, :part_id => part_article.part_id, :article_id => part_article.article_id)
      #get article paragraphs
      article_paragraphs = StandardArticleParagraph.find(:all, :conditions => {:standard_part_article_id => part_article.id})
      for article_paragraph in article_paragraphs
        #create new article paragraph
        new_article_paragraph = ArticleParagraph.create(:part_article_id => new_part_article.id, :paragraph_id => article_paragraph.paragraph_id)
        #get sub paragraph
        subparagraphs = StandardSubparagraph.find(:all, :conditions => {:standard_article_paragraph_id => article_paragraph.id})
        for subparagraph in subparagraphs
          #create new subparagraph
          new_subparagraph = Subparagraph.create(:article_paragraph_id => new_article_paragraph.id, :description => subparagraph.description, :user_id => subparagraph.user_id)
        end
      end
      #user defined
      user_paragraphs = StandardUserParagraph.find(:all, :conditions => {:standard_part_article_id => part_article.id})
      for paragraph in user_paragraphs
        #create new article paragraph
        new_user_paragraph = UserParagraph.create(:part_article_id => new_part_article.id, :name => paragraph.name, :paragraph => paragraph.paragraph, :user_id => paragraph.user_id)
        #get sub paragraph
        subparagraphs = StandardUserSubparagraph.find(:all, :conditions => {:standard_user_paragraph_id => paragraph.id})
        for subparagraph in subparagraphs
          #create new subparagraph
          new_subparagraph = UserSubparagraph.create(:user_paragraph_id => new_user_paragraph.id, :description => subparagraph.description, :user_id => subparagraph.user_id)
        end
      end
    end
    
    user_articles = StandardUserArticle.find(:all, :conditions => {:standard_section_id => @standard_section.id})
    for user_article in user_articles
      #create new part article
      new_user_article = UserArticle.create(:specification_section_id => @specification_section.id, :part_id => 1, :name => user_article.name, :user_id => user_article.user_id)
      #user defined
      user_paragraphs = StandardUserParagraph.find(:all, :conditions => {:standard_user_article_id => user_article.id})
      for paragraph in user_paragraphs
        #create new article paragraph
        new_user_paragraph = UserParagraph.create(:user_article_id => new_user_article.id, :paragraph => paragraph.paragraph, :user_id => paragraph.user_id)
        #get sub paragraph
        subparagraphs = StandardUserSubparagraph.find(:all, :conditions => {:standard_user_paragraph_id => paragraph.id})
        for subparagraph in subparagraphs
          #create new subparagraph
          new_subparagraph = UserSubparagraph.create(:user_paragraph_id => new_user_paragraph.id, :description => subparagraph.description, :user_id => subparagraph.user_id)
        end
      end
    end
    
    redirect_to new_spec_sec_part_path(:job_id => @specification_section.specification.job.id, :specification_section_id => @specification_section.id)
  end
end
