class JobsController < ApplicationController
  before_filter :login_required, :warning
  access_control do
    allow :admin
    allow :manager, :except => [:new, :create, :edit, :update, :destroy]
    allow :team, :to => [:index, :show]
  end
  
 def index
    @search = Job.search(params[:search])
    @jobs = @search.client_user_id_eq(as_user).is_archive_eq(false).paginate(:per_page => 20, :page => params[:page])
    @collaborators = Collaborator.email_eq(current_user.email)
  end

  def archive

    @job = Job.find(params[:id])
    @job.is_archive = true
    @job.save
    redirect_to client_path(@job.client)
  end

  def archived_job
    
    @jobs = Job.client_user_id_eq(as_user).is_archive_eq(true).paginate(:per_page => 20, :page => params[:page])
  end

  
  def show
    @job = Job.find(params[:id], :include => [{:specifications => :specification_sections}, :client], :order => "specifications.division_id ASC, specification_sections.section_id ASC", :conditions => ["clients.user_id = #{as_user}"])
    @client = @job.client
  end
  
  def shared
    @collaborator = Collaborator.find(params[:collaborator_id])
    @job = Job.find(params[:job_id], :include => [{:specifications => :specification_sections}, :client], :order => "specifications.division_id ASC, specification_sections.section_id ASC", :conditions => ["clients.user_id = #{@collaborator.user_id}"])
    @client = @job.client
  end

  def show_all
    @parts = Part.find(:all)
    @job = Job.find(params[:job_id], :include => [{:specifications => :specification_sections}], :order => "specifications.division_id ASC, specification_sections.section_id ASC")

    respond_to do |format|
      format.html
      format.pdf {
        dir = RAILS_ROOT + "/tmp/pdfs/"+@job.id.to_s
        FileUtils.mkdir_p(dir)

        if @job.layout_id.blank? || @job.layout_id == 1 || @job.layout_id == 3
          table_of_content_pages = Hash.new
          for specification in @job.specifications
            specification_sections = SpecificationSection.specification_id_eq(specification.id)
            for specification_section in specification_sections
              pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )


              if report_article_number(specification_section.specification.division.short_number) != "00"


                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
                  pdf.text "SECTION #{specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  pdf.text "#{specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = PartArticle.part_id_eq(part.id).specification_section_id_eq(specification_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
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
                    pdf.move_down(5)
                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                  table_of_content_pages[specification_section.id] = pdf.page_count
                end # end of bounding box
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              else

                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

                  main = [[{:text => "#{specification_section.section.report_number}  #{specification_section.section.name.upcase}", :font_style => :bold}]]
                  pdf.table main, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0

                  pdf.move_down(5)


                  pdf.move_down(10)
                  @articles = UserArticle.find_all_by_specification_section_id(specification_section.id)
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
                      :column_widths => {0 => 25, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      a = a + 1
                    end

                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                    :column_widths => {0 => 25, 1 => 380},
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
                          :column_widths => {0 => 20, 1 => 25, 2 => 415},
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
                table_of_content_pages[specification_section.id] = pdf.page_count
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw


                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw

                end



              end
              File.open(dir + "/"+ specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }

              pdf = nil

            end

          end
        elsif @job.layout_id == 2
          table_of_content_pages = Hash.new
          for specification in @job.specifications
            specification_sections = SpecificationSection.specification_id_eq(specification.id)
            for specification_section in specification_sections
              pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
              if report_article_number(specification_section.specification.division.short_number) != "00"
                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
                  pdf.text "SECTION #{specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  pdf.text "#{specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = PartArticle.part_id_eq(part.id).specification_section_id_eq(specification_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
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
                    pdf.move_down(5)
                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                  table_of_content_pages[specification_section.id] = pdf.page_count
                end # end of bounding box
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              else
                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

                  main = [[{:text => "#{specification_section.section.report_number}  #{specification_section.section.name.upcase}", :font_style => :bold}]]
                  pdf.table main, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0

                  pdf.move_down(5)


                  pdf.move_down(10)
                  @articles = UserArticle.find_all_by_specification_section_id(specification_section.id)
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
                      :column_widths => {0 => 25, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      a = a + 1
                    end

                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                    :column_widths => {0 => 25, 1 => 380},
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
                          :column_widths => {0 => 20, 1 => 25, 2 => 415},
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
                table_of_content_pages[specification_section.id] = pdf.page_count
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw


                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw

                end

              end
              File.open(dir + "/"+ specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }
              pdf = nil
            end
          end
        elsif @job.layout_id == 4
          table_of_content_pages = Hash.new
          for specification in @job.specifications
            specification_sections = SpecificationSection.specification_id_eq(specification.id)
            for specification_section in specification_sections
              pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
              if report_article_number(specification_section.specification.division.short_number) != "00"
                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
                  pdf.text "#{specification_section.section.report_number} - #{specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)

                  for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = PartArticle.part_id_eq(part.id).specification_section_id_eq(specification_section.id)
                    a = 1

                    for article in articles
                      articles = [[{:text => article.article.name.upcase, :font_style => :bold}]]
                      pdf.table articles, :font_size => 9, :style => :bold,
                      :column_widths => {0 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 97
                      c = 1
                      for paragraph in article.article_paragraphs
                        for subparagraph in paragraph.subparagraphs
                          subparagraphs = [["",subparagraph.description]]
                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 40, 1 => 420},
                          :inline_format => true,
                          :position => :left,
                          :vertical_padding => 1,
                          :border_width => 0,
                          :align => {2 => :left}
                          pdf.move_down(5)
                          c += 1
                        end
                        b += 1
                      end
                      a += 1
                    end
                    pdf.move_down(5)
                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                  table_of_content_pages[specification_section.id] = pdf.page_count
                end # end of bounding box
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              else

                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

                  main = [[{:text => "#{specification_section.section.report_number}  #{specification_section.section.name.upcase}", :font_style => :bold}]]
                  pdf.table main, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0

                  pdf.move_down(5)


                  pdf.move_down(10)
                  @articles = UserArticle.find_all_by_specification_section_id(specification_section.id)
                  puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
                  puts specification_section.id
                  puts @articles.inspect
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
                      :column_widths => {0 => 25, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      a = a + 1
                    end

                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                    :column_widths => {0 => 25, 1 => 380},
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
                      :border_width  => 0
                      pdf.move_down(5)
                      b = 97
                      c = 1
                      for paragraph in article.user_paragraphs
                        paragraphs = [["#{b.chr.upcase}.", paragraph.paragraph]]
                        pdf.table paragraphs, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 25, 1 => 440},
                        :inline_format => true,
                        :position => :left,
                        :vertical_padding => 1,
                        :border_width       => 0,
                        :align => {2 => :left}
                        pdf.move_down(5)
                        for subparagraph in paragraph.user_subparagraphs
                          subparagraphs = [["","#{c}.",subparagraph.description]]
                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 20, 1 => 25, 2 => 415},
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
                table_of_content_pages[specification_section.id] = pdf.page_count
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw


                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw

                end
              end
              File.open(dir + "/"+ specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }
              pdf = nil
            end
          end
        elsif @job.layout_id == 5
          table_of_content_pages = Hash.new
          for specification in @job.specifications
            specification_sections = SpecificationSection.specification_id_eq(specification.id)
            for specification_section in specification_sections
              pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
              if report_article_number(specification_section.specification.division.short_number) != "00"
                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
                  pdf.text "SECTION #{specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  pdf.text "#{specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = PartArticle.part_id_eq(part.id).specification_section_id_eq(specification_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
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
                    pdf.move_down(5)
                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                  table_of_content_pages[specification_section.id] = pdf.page_count
                end # end of bounding box
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              else

                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

                  main = [[{:text => "#{specification_section.section.report_number}  #{specification_section.section.name.upcase}", :font_style => :bold}]]
                  pdf.table main, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0

                  pdf.move_down(5)


                  pdf.move_down(10)
                  @articles = UserArticle.find_all_by_specification_section_id(specification_section.id)
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
                      :column_widths => {0 => 25, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      a = a + 1
                    end

                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
                  if attachments.size > 0
                    pdf.move_down(10)

                    attach = [[{:text => "Attachments", :font_style => :bold}]]
                    pdf.table attach, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 200},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width => 0

                    ind = 1
                  end
                  for attachment in attachments
                    attach = [[{:text => "#{ind}."}, {:text => "#{attachment.title}"}]]
                    pdf.table attach, :font_size => 9,
                    :column_widths => {0 => 25, 1 => 380},
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
                          :column_widths => {0 => 20, 1 => 25, 2 => 415},
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
                table_of_content_pages[specification_section.id] = pdf.page_count
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw


                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw

                end
              end
              File.open(dir + "/"+ specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }
              pdf = nil
            end
          end
        elsif @job.layout_id == 6
          table_of_content_pages = Hash.new
          for specification in @job.specifications
            specification_sections = SpecificationSection.specification_id_eq(specification.id)
            for specification_section in specification_sections
              pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
              if report_article_number(specification_section.specification.division.short_number) != "00"
                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
                  pdf.text "SECTION #{specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  pdf.text "#{specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = PartArticle.part_id_eq(part.id).specification_section_id_eq(specification_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
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
                    pdf.move_down(5)
                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                  table_of_content_pages[specification_section.id] = pdf.page_count
                end # end of bounding box
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              else

                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

                  main = [[{:text => "#{specification_section.section.report_number}  #{specification_section.section.name.upcase}", :font_style => :bold}]]
                  pdf.table main, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0

                  pdf.move_down(5)


                  pdf.move_down(10)
                  @articles = UserArticle.find_all_by_specification_section_id(specification_section.id)

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
                      :column_widths => {0 => 25, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      a = a + 1
                    end

                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                    :column_widths => {0 => 25, 1 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width => 0

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
                      :border_width => 0
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
                          :column_widths => {0 => 20, 1 => 25, 2 => 415},
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
                table_of_content_pages[specification_section.id] = pdf.page_count
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw


                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              end
              File.open(dir + "/"+ specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }
              pdf = nil
            end
          end
        elsif @job.layout_id == 7
          table_of_content_pages = Hash.new
          for specification in @job.specifications
            specification_sections = SpecificationSection.specification_id_eq(specification.id)
            for specification_section in specification_sections
              pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
              if report_article_number(specification_section.specification.division.short_number) != "00"
                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
                  pdf.text "SECTION #{specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  pdf.text "#{specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                  pdf.move_down(5)
                  for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = PartArticle.part_id_eq(part.id).specification_section_id_eq(specification_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
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
                    pdf.move_down(5)
                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                  table_of_content_pages[specification_section.id] = pdf.page_count
                end # end of bounding box
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw
                  pdf.lazy_bounding_box([pdf.bounds.left  + 3, pdf.bounds.top], :width =>250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              else

                pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

                  main = [[{:text => "#{specification_section.section.report_number}  #{specification_section.section.name.upcase}", :font_style => :bold}]]
                  pdf.table main, :font_size => 9, :style => :bold,
                  :column_widths => {0 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width       => 0

                  pdf.move_down(5)


                  pdf.move_down(10)
                  @articles = UserArticle.find_all_by_specification_section_id(specification_section.id)

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
                      :column_widths => {0 => 25, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      a = a + 1
                    end

                  end
                  attachments = SectionAttachment.specification_section_id_eq(specification_section.id)
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
                    :column_widths => {0 => 25, 1 => 380},
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
                          :column_widths => {0 => 20, 1 => 25, 2 => 415},
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
                table_of_content_pages[specification_section.id] = pdf.page_count
                pdf.page_count.times do |i|
                  pdf.go_to_page(i+1)
                  pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
                  }.draw


                  pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
                  }.draw

                  pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {

                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
                    pdf.text "#{specification_section.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
                  }.draw
                end
              end
              File.open(dir + "/"+ specification_section.section.number+ ".pdf", "w") { |f| f.write pdf.render }
              pdf = nil
            end
          end
        end

        pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
        pdf.font "Helvetica"
        pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
          pdf.text "TABLE OF CONTENTS", :align => :center, :size => 9, :style => :bold
          pdf.move_down(10)

          for specification in @job.specifications
            #pdf.text "DIVISION #{specification.division.search_number} - #{specification.division.name}".upcase, :style => :bold, :size => 9
            pdf.move_down(10)
            toc_title = [[{:text => specification.division.modif_number, :font_style => :bold},{:text => specification.division.name, :font_style => :bold}]]
            pdf.table toc_title, :font_size => 9, :font_style => :bold,
            :column_widths => {0 => 65, 1 => 340},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0

            if(!specification.specification_sections.blank?)
              specification.specification_sections.each do |item|
                toc = [["","#{item.section.modif_number}",item.section.name, table_of_content_pages[item.id]]]

                pdf.table toc, :font_size => 9,
                :border_style => :grid,
                :column_widths => {0 => 65, 1 => 65, 2 => 328, 3 => 25},
                :position => :left,
                :vertical_padding => 2,
                :border_width => 0

                attachments = SectionAttachment.specification_section_id_eq(item.id)
                if attachments.size > 0
                  ind = 1
                  for attachment in attachments
                    attach = [["","#{ind}","", "#{attachment.title}"]]
                    pdf.table attach, :font_size => 9,
                    :column_widths => {0 => 65, 1 => 45, 2 => 20, 3 => 340},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    ind = ind + 1
                  end
                end

              end
            end
          end

          pdf.move_down(15)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
        end
        pdf.page_count.times do |i|
          pdf.go_to_page(i+1)
          pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
          }.draw

          pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
          }.draw
          pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
            pdf.text "#{@job.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
          }.draw
          pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
            pdf.text "#{@job.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
          }.draw
        end
        File.open(dir +  "/#{@job.number}-content.pdf", "w") { |f| f.write pdf.render }


        #SECTION FOR NOTE CREATION

        pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
        pdf.font "Helvetica"
        pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do
          pdf.text "NOTES", :align => :center, :size => 9, :style => :bold
          for specification in @job.specifications
            pdf.move_down(10)
            toc_title = [[{:text => specification.division.modif_number, :font_style => :bold},{:text => specification.division.name, :font_style => :bold}]]
            pdf.table toc_title, :font_size => 9, :font_style => :bold,
            :column_widths => {0 => 50, 1 => 340},
            :position => :left,
            :vertical_padding => 2,
            :border_width       => 0
            if(!specification.specification_sections.blank?)
              specification.specification_sections.each do |item|
                notes = SectionNote.specification_section_id_eq(item.id)
                @ccf = CloudFiles::Connection.new(CLOUD_CONFIG['username'],CLOUD_CONFIG['api_key'])
                container = @ccf.container(CLOUD_CONFIG['container'])

                @attachments = SectionAttachment.specification_section_id_eq(item.id)
                #get all attachments
                i = 1
                for attachment in @attachments
                  object = container.object(attachment.asset.path)
                  tmp = File.open(dir + "/"+attachment.specification_section.section.number.to_s+"-"+i.to_s+".pdf", "w+")
                  tmp.syswrite(object.data)
                  i += 1
                end
                if notes.size > 0
                  attach = [["","#{item.section.modif_number}", "#{item.section.name}"]]
                  pdf.table attach, :font_size => 9,
                  :column_widths => {0 => 50, 1 => 65, 2 => 380},
                  :position => :left,
                  :vertical_padding => 2,
                  :border_width  => 0



                  ind = 1
                  for note in notes
                    attach = [["","","#{ind}.", "#{note.note}"]]
                    pdf.table attach, :font_size => 9,
                    :column_widths => {0 => 50, 1 => 65, 2 => 25, 3 => 320},
                    :position => :left,
                    :align => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    ind = ind + 1
                  end
                end

              end
            end
          end
          pdf.move_down(15)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
        end
        pdf.page_count.times do |i|
          pdf.go_to_page(i+1)
          pdf.lazy_bounding_box([pdf.bounds.right - 245, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_right_1, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_right_2, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_right_3, pdf)}", :size => 9, :align => :right
          }.draw
          pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_left_1, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_left_2, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.bottom_left_3, pdf)}", :size => 9, :align => :left
          }.draw
          pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
            pdf.text "#{@job.choose_option(@job.job_page_format.top_right_1, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.top_right_2, pdf)}", :size => 9, :align => :right
            pdf.text "#{@job.choose_option(@job.job_page_format.top_right_3, pdf)}", :size => 9, :align => :right
          }.draw
          pdf.lazy_bounding_box([pdf.bounds.left + 3, pdf.bounds.top], :width =>250, :align => :left) {
            pdf.text "#{@job.choose_option(@job.job_page_format.top_left_1, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.top_left_2, pdf)}", :size => 9, :align => :left
            pdf.text "#{@job.choose_option(@job.job_page_format.top_left_3, pdf)}", :size => 9, :align => :left
          }.draw
        end
        File.open(dir + "/#{@job.number}-notes.pdf", "w") { |f| f.write pdf.render }
        pdf = nil
        path = RAILS_ROOT + "/tmp/pdfs/"+@job.id.to_s
        @processes = `zip "tmp/pdfs/#{@job.number.to_s}.zip" tmp/pdfs/#{@job.id}/*`
        @processes = `pwd`
        #puts @processes
        send_file(RAILS_ROOT + "/tmp/pdfs/"+@job.number.to_s+".zip", :type => "application/zip", :filename => @job.number+".zip" )
        #t.close
        #redirect_to @job
      }
    end
  end



  def show_notes
    @parts = Part.find(:all)
    @job = Job.find(params[:job_id], :include => [{:specifications => :specification_sections}], :order => "specifications.division_id ASC, specification_sections.section_id ASC")
  end

  def new
    if params[:client_id] != nil
      @client = Client.find(params[:client_id])
      @job = Job.new(:client_id => params[:client_id])
    else
      @job = Job.new
    end
  end

  def template_list
    @template_jobs = TemplateJob.all
  end

  def new_from_template
    @job = Job.new(:client_id => params[:client_id])
    @template_jobs = TemplateJob.all
  end

  def create_from_template
    #get the template job
    template_job = TemplateJob.find(params[:template_id])
    #create new job
    @job = Job.new(params[:job])
    if @job.save
      #get template job specifications
      specifications = Specification.job_id_equals(template_job.job_id)
      for specification in specifications
        #create new job specifications
        new_spec = Specification.create(:job_id => @job.id, :division_id => specification.division_id)
        #get specification sections
        specification_sections = SpecificationSection.find(:all, :conditions => {:specification_id => specification.id})
        for specification_section in specification_sections
          #create new section
          new_specification_section = SpecificationSection.create(:specification_id => new_spec.id, :section_id => specification_section.section_id)
        end
      end
      flash[:notice] = "Job successfully created from template."
      redirect_to @job
    else
      render :action => 'new'
    end
  end

  def create
    # template_job = TemplateJob.find(params[:job][:template_id])
    @client = Client.find(params[:job][:client_id])
    @job = Job.new(params[:job])
    if (@job.template_job_id == nil || @job.template_job_id == "")
      @job.template_job_id = 1
    end
    
    if @job.save
      @job.layout_id = params[:job][:layout_id]
      @job.save
      @admin_format = AdminFormat.find(User.find(as_user).admin_format.id)
      @job_page_format = JobPageFormat.create(:job_id => @job.id,
        :top_left_1 => @admin_format.top_left_1,
        :top_left_2 => @admin_format.top_left_2,
        :top_left_3 => @admin_format.top_left_3,
        :top_right_1 => @admin_format.top_right_1,
        :top_right_2 => @admin_format.top_right_2,
        :top_right_3 => @admin_format.top_right_3,
        :bottom_left_1 => @admin_format.bottom_left_1,
        :bottom_left_2 => @admin_format.bottom_left_2,
        :bottom_left_3 => @admin_format.bottom_left_3,
        :bottom_right_1 =>  @admin_format.bottom_right_1,
        :bottom_right_2 =>  @admin_format.bottom_right_2,
        :bottom_right_3 =>  @admin_format.bottom_right_3
      )
      flash[:notice] = "Job successfully created."
      redirect_to @job
    else
      params[:client_id] = @client.id
      render :action => 'new'
    end
  end

  def edit
    @job = Job.find(params[:id])
    @client = @job.client
  end

  def update
    
    @job = Job.find(params[:id])
    if @job.update_attributes(params[:job])
       if (@job.template_job_id == nil || @job.template_job_id == "")
          @job.template_job_id = 1
          @job.save
        end

      flash[:notice] = "Job successfully updated."
      redirect_to @job
    else
      render :action => 'edit'
    end
  end

  def destroy
    @job = Job.find(params[:id])
    if @job.specifications.count > 0
      flash[:warning] = "You need to remove all divisions and sections first."
    else
      @job.destroy
      flash[:notice] = "Job successfully removed."
    end
    #redirect_to client_path(client_id)
    redirect_to jobs_path
  end

  def destroy_archived_job
    @job = Job.find(params[:id])
    @job.destroy
    flash[:notice] = "Job successfully removed."
    #redirect_to client_path(client_id)
    redirect_to "/jobs/archived_job"
  end
  

  def add_multiple_divisions
    @job = Job.find(params[:job_id])
    @client = @job.client
    @template_job = TemplateJob.find(@job.template_job_id)
    @have_specifications = Specification.job_id_eq(@job.id).ascend_by_division_id
    @divisions = have_divisions(@job.id, @template_job.id)
    @specification = Specification.new(:job_id => params[:job_id])
  end

  def create_multiple_divisions
    @job =  Job.find(params[:specification][:job_id])
    @template_job = TemplateJob.find(@job.template_job_id)
    divisions = have_divisions(@job.id, @template_job.id)
    for division in divisions
      if params[:divisions][division.id.to_s][:id] == "1"
        Specification.create(:job_id => params[:specification][:job_id], :division_id => division.id )
      end
    end
    flash[:notice] = "Divisions has been added successfully."
    redirect_to job_path(params[:specification][:job_id])
  end

  def add_div_from_master
    @job = Job.find(params[:job_id])
    @client = @job.client
    @divisions = have_div_masters(@job.id)
    @specification = Specification.new(:job_id => params[:job_id])
  end

  def create_div_from_master
    @job =  Job.find(params[:specification][:job_id])
    divisions = have_div_masters(@job.id)
    for division in divisions
      if params[:divisions][division.id.to_s][:id] == "1"
        Specification.create(:job_id => params[:specification][:job_id], :division_id => division.id )
      end
    end
    flash[:notice] = "Divisions has been added successfully."
    redirect_to job_path(params[:specification][:job_id])
  end

  def add_multiple_sections
    @specification = Specification.find(params[:specification_id])
    @job = @specification.job
    @client = @job.client
    @template_job = TemplateJob.find(@specification.job.template_job_id)
    @template_specification = TemplateSpecification.template_job_id_eq(@template_job.id).division_id_eq(@specification.division_id)
    @have_specification_sections = SpecificationSection.specification_id_eq(@specification.id).ascend_by_section_id
    @sections = have_sections(@specification, @template_specification)
    @specification_section = SpecificationSection.new(:specification_id => params[:specification_id])
  end

  #for shared
  def add_sections
    @specification = Specification.find(params[:specification_id])
    @job = @specification.job
    @client = @job.client
    @template_job = TemplateJob.find(@specification.job.template_job_id)
    @template_specification = TemplateSpecification.template_job_id_eq(@template_job.id).division_id_eq(@specification.division_id)
    @have_specification_sections = SpecificationSection.specification_id_eq(@specification.id).ascend_by_section_id
    @sections = have_sections(@specification, @template_specification)
    @specification_section = SpecificationSection.new(:specification_id => params[:specification_id])
  end
  
  def create_sections
    @collaborator = Collaborator.find(params[:collaborator_id])
    specification = Specification.find(params[:specification_section][:specification_id])
    @template_job = TemplateJob.find(specification.job.template_job_id)
    @template_specification = TemplateSpecification.template_job_id_eq(@template_job.id).division_id_eq(specification.division_id)
    sections = have_sections(specification.id, @template_specification)
    for section in sections
      if params[:sections][section.id.to_s][:id] == "1"
        SpecificationSection.create(:specification_id => params[:specification_section][:specification_id], :section_id => section.id, :user_id => current_user.id, :owner_id => current_user.id)
      end
    end
    flash[:notice] = "Sections has been added successfully."
    redirect_to shared_job_path(:job_id => specification.job.id, :collaborator_id => @collaborator.id)
  end
  
  def add_master
    @specification = Specification.find(params[:specification_id])
    @sections = have_masters(@specification.id, @specification.division.search_number)
    @specification_section = SpecificationSection.new(:specification_id => params[:specification_id])
  end

  def create_master
    @collaborator = Collaborator.find(params[:collaborator_id])
    specification = Specification.find(params[:specification_section][:specification_id])
    sections = have_masters(specification.id, specification.division.search_number)
    for section in sections
      if params[:sections][section.id.to_s][:id] == "1"
        SpecificationSection.create(:specification_id => params[:specification_section][:specification_id], :section_id => section.id, :user_id => current_user.id, :owner_id => current_user.id)
      end
    end
    flash[:notice] = "Sections has been added successfully."
    redirect_to shared_job_path(:job_id => specification.job.id, :collaborator_id => @collaborator.id)
  end
  
  #end
  def create_multiple_sections
    specification = Specification.find(params[:specification_section][:specification_id])
    @template_job = TemplateJob.find(specification.job.template_job_id)
    @template_specification = TemplateSpecification.template_job_id_eq(@template_job.id).division_id_eq(specification.division_id)
    sections = have_sections(specification.id, @template_specification)
    for section in sections
      if params[:sections][section.id.to_s][:id] == "1"
        SpecificationSection.create(:specification_id => params[:specification_section][:specification_id], :section_id => section.id, :owner_id => current_user.id)
      end
    end
    flash[:notice] = "Sections has been added successfully."
    redirect_to job_path(specification.job_id)
  end

  def add_from_master
    @specification = Specification.find(params[:specification_id])
    @sections = have_masters(@specification.id, @specification.division.search_number)
    @specification_section = SpecificationSection.new(:specification_id => params[:specification_id])
  end



  def create_from_master
    specification = Specification.find(params[:specification_section][:specification_id])
    sections = have_masters(specification.id, specification.division.search_number)
    for section in sections
      if params[:sections][section.id.to_s][:id] == "1"
        SpecificationSection.create(:specification_id => params[:specification_section][:specification_id], :section_id => section.id, :owner_id => current_user.id)
      end
    end
    flash[:notice] = "Sections has been added successfully."
    redirect_to job_path(specification.job_id)
  end

  def have_divisions(job_id, template_job_id)
    have_specifications = Specification.job_id_eq(job_id)
    x = 0
    have_divs = Array.new
    have_divs[x] = 0
    for have_spec in have_specifications
      have_divs[x] = have_spec.division_id
      x = x + 1
    end

    specifications = TemplateSpecification.template_job_id_eq(template_job_id)
    x = 0
    divs = Array.new
    divs[x] = 0
    for spec in specifications
      divs[x] = spec.division_id
      x = x + 1
    end
  
 
    puts divs.inspect
    divisions = Division.id_eq(divs).id_does_not_equal(have_divs)
    return divisions
  end

  def have_sections(specification_id, template_specification_id)
    have_sections = SpecificationSection.specification_id_eq(specification_id)
    x = 0
    have_secs = Array.new
    have_secs[x] = 0
    for have_section in have_sections
      have_secs[x] = have_section.section_id
      x = x + 1
    end

    sections = TemplateSpecificationSection.template_specification_id_eq(template_specification_id)
    x = 0
    secs = Array.new
    secs[x] = 0
    for section in sections
      secs[x] = section.section_id
      x = x + 1
    end
    sections = Section.id_eq(secs).id_does_not_equal(have_secs)
    return sections
  end

  def have_masters(specification_id, division_number)
    sections = SpecificationSection.specification_id_eq(specification_id)
    x = 0
    secs = Array.new
    secs[x] = 0
    for section in sections
      secs[x] = section.section_id
      x = x + 1
    end
    sections = Section.id_does_not_equal(secs).number_begins_with(division_number).number_not_begin_with("#{division_number}00")
    return sections
  end

  def have_div_masters(job_id)
    have_specifications = Specification.job_id_eq(job_id)
    x = 0
    have_divs = Array.new
    have_divs[x] = 0
    for have_spec in have_specifications
      have_divs[x] = have_spec.division_id
      x = x + 1
    end

    divisions = Division.id_does_not_equal(have_divs)
    #divisions = Division.id_eq(divs).id_does_not_equal(have_divs)
    return divisions
  end
end
