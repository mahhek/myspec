# pdf.font "Helvetica"
# if @job.layout_id == 1
#   pdf.repeat :all do
#       #header left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_1), :at =>[pdf.bounds.left, pdf.bounds.top+60] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_2), :at =>[pdf.bounds.left, pdf.bounds.top+45] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_3), :at =>[pdf.bounds.left, pdf.bounds.top+30] , :width => 100
#       
#       #header right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.top+60], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.top+45] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_3), :at =>[pdf.bounds.right-100, pdf.bounds.top+30], :width => 100, :align => :right
#       
#       #footer left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_1), :at =>[pdf.bounds.left, pdf.bounds.bottom+42] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_2), :at =>[pdf.bounds.left, pdf.bounds.bottom+27] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_3), :at =>[pdf.bounds.left, pdf.bounds.bottom+12] , :width => 100
#       
#       #footer right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+42], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+27] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_3,pdf), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+12], :width => 100, :align => :right
#   end
#   pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
#   pdf.move_down(5)
#   pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
#   pdf.move_down(10)
#   
#   for part in @parts
#     parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
#     pdf.table parts, :font_size => 9, :style => :bold,
#       :column_widths => {0 => 380},
#       :position => :left,
#       :vertical_padding => 2,
#       :border_width       => 0
#     pdf.move_down(5)
#     if part.id == 1
#       a = 1
#       for article in @list_general_articles
#         articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 35, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 97
#         for paragraph in article.article_paragraphs
#           paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 20, 1 => 20, 2 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 1
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","#{c}.",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 2
#       a = 1
#       for article in @list_product_articles
#         articles = [[{:text => "#{part.id}.#{report_article_number(a)}.", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 35, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 97
#         for paragraph in article.article_paragraphs
#           paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 20, 1 => 20, 2 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 1
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","#{c}.",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 3
#       a = 1
#       for article in @list_execution_articles
#         articles = [[{:text => "#{part.id}.#{report_article_number(a)}.", :font_style => :bold},{:text => article.article.name, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 35, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 97
#         for paragraph in article.article_paragraphs
#           paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 20, 1 => 20, 2 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 1
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","#{c}.",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     end
#     pdf.move_down(10)
#   end
#   #pdf.start_new_page
#   attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
#   for attachment in attachments
#     #File.open(attachment.asset.path)
#   end
# elsif @job.layout_id == 2
#   pdf.repeat :all do
#       #header left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_1), :at =>[pdf.bounds.left, pdf.bounds.top+60] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_2), :at =>[pdf.bounds.left, pdf.bounds.top+45] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_3), :at =>[pdf.bounds.left, pdf.bounds.top+30] , :width => 100
#       
#       #header right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.top+60], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.top+45] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_3), :at =>[pdf.bounds.right-100, pdf.bounds.top+30], :width => 100, :align => :right
#       
#       #footer left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_1), :at =>[pdf.bounds.left, pdf.bounds.bottom+27] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_2), :at =>[pdf.bounds.left, pdf.bounds.bottom+12] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_3), :at =>[pdf.bounds.left, pdf.bounds.bottom] , :width => 100
#       
#       #footer right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+42], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+27] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_3,pdf), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+12], :width => 100, :align => :right
#   end
#   pdf.text "SECTION #{@specification_section.section.report_number}", :align => :center, :size => 9, :style => :bold
#   pdf.move_down(5)
#   pdf.text "#{@specification_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
#   pdf.move_down(10)
# 
#   for part in @parts
#     parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
#     pdf.table parts, :font_size => 9, :style => :bold,
#       :column_widths => {0 => 380},
#       :position => :left,
#       :vertical_padding => 2,
#       :border_width       => 0
#     pdf.move_down(5)
#     if part.id == 1
#       a = 1
#       for article in @list_general_articles
#         articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 25, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["#{part.id}.#{a}.#{b}",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 35, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","#{c.chr}.",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 2
#       a = 1
#       for article in @list_product_articles
#         articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 25, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["#{part.id}.#{a}.#{b}",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 35, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","#{c.chr}.",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 3
#       a = 1
#       for article in @list_execution_articles
#         articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 25, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["#{part.id}.#{a}.#{b}",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 35, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","#{c.chr}.",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     end
#     pdf.move_down(10)
#   end
#   
#   # footer
#     pdf.page_count.times do |i|
#       pdf.go_to_page(i+1)
#       pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 8], :width => 100) {
#         pdf.text "#{@job.created_at.strftime('%Y')} / #{@job.name.upcase}", :align => :left, :size => 7
#       }.draw
#       pdf.lazy_bounding_box([pdf.bounds.right/2 - 1.in, pdf.bounds.bottom + 8], :width => 100) {
#         pdf.text "#{@specification_section.section.report_number} - #{i+1}", :align => :right, :size => 7
#       }.draw
#       pdf.lazy_bounding_box([pdf.bounds.right-1.5.in, pdf.bounds.bottom + 8], :width => 100) {
#         #pdf.text "#{i+1} / #{pdf.page_count}", :align => :right, :size => 8
#         pdf.text "#{@specification_section.section.name.upcase}", :align => :right, :size => 7
#       }.draw
#     end
# elsif @job.layout_id == 3
#   pdf.repeat :all do
#       #header left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_1), :at =>[pdf.bounds.left, pdf.bounds.top+60] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_2), :at =>[pdf.bounds.left, pdf.bounds.top+45] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_3), :at =>[pdf.bounds.left, pdf.bounds.top+30] , :width => 100
#       
#       #header right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.top+60], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.top+45] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_3), :at =>[pdf.bounds.right-100, pdf.bounds.top+30], :width => 100, :align => :right
#       
#       #footer left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_1), :at =>[pdf.bounds.left, pdf.bounds.bottom+27] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_2), :at =>[pdf.bounds.left, pdf.bounds.bottom+12] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_3), :at =>[pdf.bounds.left, pdf.bounds.bottom] , :width => 100
#       
#       #footer right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+42], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+27] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_3,pdf), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+12], :width => 100, :align => :right
#   end
#   sections = [
#     [{:text => "SECTION #{@specification_section.section.report_number}", :font_style => :bold}],
#     [{:text => "#{@specification_section.section.name.upcase}", :font_style => :bold}]
#     ]
#   pdf.table sections, :font_size => 9, :style => :bold,
#     :column_widths => {0 => 380},
#     :position => :left,
#     :vertical_padding => 2,
#     :border_width       => 0
# 
# 
#   for part in @parts
#     parts = [[{:text => "PART #{part.id}  #{part.name.upcase}", :font_style => :bold}]]
#     pdf.table parts, :font_size => 9, :style => :bold,
#       :column_widths => {0 => 380},
#       :position => :left,
#       :vertical_padding => 2,
#       :border_width       => 0
#     pdf.move_down(10)
#     if part.id == 1
#       a = 1
#       for article in @list_general_articles
#         articles = [[{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 35, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 2
#       a = 1
#       for article in @list_product_articles
#         articles = [[{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 35, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 3
#       a = 1
#       for article in @list_execution_articles
#         articles = [[{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(10)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 35, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["","",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 40, 1 => 20, 2 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     end
#     pdf.move_down(10)
#   end
#   pdf.page_count.times do |i|
#     pdf.go_to_page(i+1)
#     pdf.lazy_bounding_box([pdf.bounds.left, pdf.bounds.bottom + 8], :width => 100) {
#       pdf.text "#{@job.created_at.strftime('%Y')} / #{@job.name.upcase}", :align => :left, :size => 7
#     }.draw
#     pdf.lazy_bounding_box([pdf.bounds.right/2 - 1.in, pdf.bounds.bottom + 8], :width => 100) {
#       pdf.text "#{@specification_section.section.report_number} - #{i+1}", :align => :right, :size => 7
#     }.draw
#     pdf.lazy_bounding_box([pdf.bounds.right-1.5.in, pdf.bounds.bottom + 8], :width => 100) {
#       #pdf.text "#{i+1} / #{pdf.page_count}", :align => :right, :size => 8
#       pdf.text "#{@specification_section.section.name.upcase}", :align => :right, :size => 7
#     }.draw
#   end
# elsif @job.layout_id == 4
#   pdf.repeat :all do
#       #header left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_1), :at =>[pdf.bounds.left, pdf.bounds.top+60] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_2), :at =>[pdf.bounds.left, pdf.bounds.top+45] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_left_3), :at =>[pdf.bounds.left, pdf.bounds.top+30] , :width => 100
#       
#       #header right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.top+60], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.top+45] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.top_right_3), :at =>[pdf.bounds.right-100, pdf.bounds.top+30], :width => 100, :align => :right
#       
#       #footer left
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_1), :at =>[pdf.bounds.left, pdf.bounds.bottom+27] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_2), :at =>[pdf.bounds.left, pdf.bounds.bottom+12] , :width => 100
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_left_3), :at =>[pdf.bounds.left, pdf.bounds.bottom] , :width => 100
#       
#       #footer right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_1), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+42], :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_2), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+27] , :width => 100, :align => :right
#       pdf.text_box @specification_section.choose_option(@job.job_page_format.bottom_right_3,pdf), :at =>[pdf.bounds.right-100, pdf.bounds.bottom+12], :width => 100, :align => :right
#   end
#   pdf.text "DIVISION #{@specification_section.specification.division.division_number[0,2]} - #{@specification_section.specification.division.name.upcase}", :align => :center, :size => 9, :style => :bold
#   pdf.move_down(5)
#   
#   sections = [
#     [{:text => "SECTION #{@specification_section.section.report_number} - #{@specification_section.section.name.upcase}", :font_style => :bold}]
#     ]
#   pdf.table sections, :font_size => 9, :style => :bold,
#     :column_widths => {0 => 380},
#     :position => :left,
#     :vertical_padding => 2,
#     :border_width       => 0
#   for part in @parts
#     pdf.move_down(5)
#     if part.id == 1
#       a = 1
#       for article in @list_general_articles
#         articles = [["",{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 20, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 40, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 60, 1 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 2
#       a = 1
#       for article in @list_product_articles
#         articles = [["",{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 20, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 40, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 60, 1 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     elsif part.id == 3
#       a = 1
#       for article in @list_execution_articles
#         articles = [["",{:text => article.article.name.upcase, :font_style => :bold}]]
#         pdf.table articles, :font_size => 9, :style => :bold,
#           :column_widths => {0 => 20, 1 => 380},
#           :position => :left,
#           :vertical_padding => 2,
#           :border_width       => 0
#         pdf.move_down(5)
#         b = 1
#         for paragraph in article.article_paragraphs
#           paragraphs = [["",paragraph.paragraph.name]]
#           pdf.table paragraphs, :font_size => 9, :style => :bold,
#             :column_widths => {0 => 40, 1 => 360},
#             :position => :left,
#             :vertical_padding => 2,
#             :border_width       => 0
#           pdf.move_down(5)
#           c = 97
#           for subparagraph in paragraph.subparagraphs
#             subparagraphs = [["",subparagraph.description]]
#             pdf.table subparagraphs, :font_size => 9, :style => :bold,
#               :column_widths => {0 => 60, 1 => 380},
#               :inline_format => true,
#               :position => :left,
#               :vertical_padding => 2,
#               :border_width       => 0,
#               :align => {2 => :left}
#             pdf.move_down(5)
#             c += 1
#           end
#           b += 1
#         end
#         a += 1
#       end
#     end
#     pdf.move_down(10)
#   end
# end