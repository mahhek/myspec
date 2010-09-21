pdf = Prawn::Document.new(:page_size => "LETTER", :top_margin => 0.5.in, :left_margin => 1.3.in, :bottom_margin => 0.in, :right_margin => 0.8.in )
        pdf.font "Helvetica"
        pdf.bounding_box([0, 700], :width => 460, :height => 610 ) do

        if report_article_number(@standard_section.section.number[0,2]) != "00"
         if @admin_format.layout_id.blank? || @admin_format.layout_id == 1 || @admin_format.layout_id == 3
        if @admin_format.show_notes
         pdf.fill_color "309030"
          note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
                      pdf.fill_color "000000"
          end
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = StandardPartArticle.part_id_eq(part.id).standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
                      if @admin_format.show_notes
                      pdf.fill_color "309030"
                      note = [[{:text => "#{article.note}"}]]
                      pdf.table note, :font_size => 9, :style => :bold,
                            :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0

                         pdf.fill_color "000000"
                      
                          unless article.note.blank?
                            pdf.move_down(5)
                          end
                      end
                      pdf.table articles, :font_size => 9, :style => :bold,
                      :column_widths => {0 => 35, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 97
                      for paragraph in article.standard_article_paragraphs
                       if @admin_format.show_notes
                      pdf.fill_color "309030"
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                       note = [[{:text => "#{paragraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end

                      pdf.fill_color "000000"
                      end
                        paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph.name]]
                        pdf.table paragraphs, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 35, 1 => 20, 2 => 380},
                        :position => :left,
                        :vertical_padding => 1,
                        :border_width       => 0
                        pdf.move_down(5)
                        c = 1
                        for subparagraph in paragraph.standard_subparagraphs
                       if @admin_format.show_notes
                        pdf.fill_color "309030"
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                        note = [[{:text => "#{subparagraph.note}"}]]                        
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                          pdf.fill_color "000000"
                          end
                          subparagraphs = [["","#{c}.",subparagraph.description]]
                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 55, 1 => 25, 2 => 395},
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
           if @admin_format.show_notes
            unless @standard_section_note.blank? || @standard_section_note.description.blank?
                 pdf.move_down(10)
                 pdf.fill_color "309030"
                note = [[{:text => "#{@standard_section_note.description}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
            end
        end
            
          pdf.fill_color "000000"
          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold
          elsif @admin_format.layout_id == 2
              if @admin_format.show_notes
            pdf.fill_color "309030"
             note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
                      pdf.fill_color "000000"
end
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = StandardPartArticle.part_id_eq(part.id).standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                       
 note = [[{:text => "#{article.note}"}]]
                      pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0

                      pdf.fill_color "000000"
                      unless article.note.blank?
                        pdf.move_down(5)
                      end
end
                       articles = [[{:text => "#{part.id}.#{a}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
                      pdf.table articles, :font_size => 9, :style => :bold,
                      :column_widths => {0 => 35, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 1
                      for paragraph in article.standard_article_paragraphs
                      d = 1
  if @admin_format.show_notes
 pdf.fill_color "309030"
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                       note = [[{:text => "#{paragraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                      pdf.fill_color "000000"

                        end
                        c = 1
                        for subparagraph in paragraph.standard_subparagraphs
  if @admin_format.show_notes
                        pdf.fill_color "309030"
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                        note = [[{:text => "#{subparagraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
end
                          pdf.fill_color "000000"
                          if d == 1
                            d = d + 1
                            subparagraphs = [["#{part.id}.#{a}.#{b}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                          else
                            subparagraphs = [["#{part.id}.#{a}.#{b}",subparagraph.description]]
                          end
                         
                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 40, 1 => 415},
                          :inline_format => true,
                          :position => :left,
                          :vertical_padding => 1,
                          :border_width       => 0,
                          :align => {2 => :left}
                          pdf.move_down(5)
                          c += 1
                            b += 1
                        end
                        pdf.move_down(5)
                        
                        end
                        a += 1
                    end
                pdf.move_down(5)
           end
  if @admin_format.show_notes
            unless @standard_section_note.blank? || @standard_section_note.description.blank?
                 pdf.move_down(10)
                 pdf.fill_color "309030"
                note = [[{:text => "#{@standard_section_note.description}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
            end

          pdf.fill_color "000000"
end
          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold

          elsif @admin_format.layout_id == 4
 if @admin_format.show_notes
 pdf.fill_color "309030"
             note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
end
                      pdf.fill_color "000000"
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = StandardPartArticle.part_id_eq(part.id).standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      note = [[{:text => "#{article.note}"}]]
                      pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0

                      pdf.fill_color "000000"
                      unless article.note.blank?
                        pdf.move_down(5)
                      end
end

                       articles = [[{:text => article.article.name.upcase, :font_style => :bold}]]
                      pdf.table articles, :font_size => 9, :style => :bold,
                      :column_widths => {0 => 460},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 1
                      for paragraph in article.standard_article_paragraphs
                      d = 1
 if @admin_format.show_notes
    pdf.fill_color "309030"
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                       note = [[{:text => "#{paragraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                      pdf.fill_color "000000"
end
                        c = 1
                        for subparagraph in paragraph.standard_subparagraphs
 if @admin_format.show_notes
                        pdf.fill_color "309030"
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                        note = [[{:text => "#{subparagraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                          pdf.fill_color "000000"
end
                          if d == 1
                            d = d + 1
                            subparagraphs = [["","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                          else
                            subparagraphs = [["",subparagraph.description]]
                          end

                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 40, 1 => 415},
                          :inline_format => true,
                          :position => :left,
                          :vertical_padding => 1,
                          :border_width       => 0,
                          :align => {2 => :left}
                          pdf.move_down(5)
                          c += 1
                            b += 1
                        end
                        pdf.move_down(5)

                        end
                        a += 1
                    end
                pdf.move_down(5)
           end
 if @admin_format.show_notes
            unless @standard_section_note.blank? || @standard_section_note.description.blank?
                 pdf.move_down(10)
                 pdf.fill_color "309030"
                note = [[{:text => "#{@standard_section_note.description}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
            end

          pdf.fill_color "000000"
end
          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold


         elsif @admin_format.layout_id == 5
 if @admin_format.show_notes
    pdf.fill_color "309030"
             note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
                      pdf.fill_color "000000"
end
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = StandardPartArticle.part_id_eq(part.id).standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      note = [[{:text => "#{article.note}"}]]
                      pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0

                      pdf.fill_color "000000"
end
                      unless article.note.blank?
                        pdf.move_down(5)
                      end
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
                      pdf.table articles, :font_size => 9, :style => :bold,
                       :column_widths => {0 => 35, 1 => 425},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 97
                      c = 1
                      for paragraph in article.standard_article_paragraphs
                      d = 1
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                       note = [[{:text => "#{paragraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                      pdf.fill_color "000000"
end
                        for subparagraph in paragraph.standard_subparagraphs
 if @admin_format.show_notes
                        pdf.fill_color "309030"
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                        note = [[{:text => "#{subparagraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                          pdf.fill_color "000000"
end
                          if d == 1
                            d = d + 1
                            subparagraphs = [["","#{c}.","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                          else
                            subparagraphs = [["","#{c}.",subparagraph.description]]
                          end

                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 35, 1 => 25, 2 => 395},
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
 if @admin_format.show_notes
            unless @standard_section_note.blank? || @standard_section_note.description.blank?
                 pdf.move_down(10)
                 pdf.fill_color "309030"
                note = [[{:text => "#{@standard_section_note.description}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
            end

          pdf.fill_color "000000"
end
          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold



        elsif @admin_format.layout_id == 6
 if @admin_format.show_notes
          pdf.fill_color "309030"
          note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
                      pdf.fill_color "000000"
end
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = StandardPartArticle.part_id_eq(part.id).standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      note = [[{:text => "#{article.note}"}]]
                      pdf.table note, :font_size => 9, :style => :bold,
                            :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0

                      pdf.fill_color "000000"
                      unless article.note.blank?
                        pdf.move_down(5)
                      end
end
                      pdf.table articles, :font_size => 9, :style => :bold,
                      :column_widths => {0 => 35, 1 => 380},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 97
                      for paragraph in article.standard_article_paragraphs
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                       note = [[{:text => "#{paragraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                      pdf.fill_color "000000"
end
                        paragraphs = [["",".#{b.chr.upcase}",paragraph.paragraph.name]]
                        pdf.table paragraphs, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 35, 1 => 20, 2 => 405},
                        :position => :left,
                        :vertical_padding => 1,
                        :border_width       => 0
                        pdf.move_down(5)
                        c = 1
                        for subparagraph in paragraph.standard_subparagraphs
 if @admin_format.show_notes
                        pdf.fill_color "309030"
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                        note = [[{:text => "#{subparagraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end


                          pdf.fill_color "000000"
end
                          subparagraphs = [["",".#{c}",subparagraph.description]]
                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 55, 1 => 25, 2 => 375},
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
 if @admin_format.show_notes
            unless @standard_section_note.blank? || @standard_section_note.description.blank?
                 pdf.move_down(10)
                 pdf.fill_color "309030"
                note = [[{:text => "#{@standard_section_note.description}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
            end

          pdf.fill_color "000000"
end
          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold


         elsif @admin_format.layout_id == 7
 if @admin_format.show_notes
  pdf.fill_color "309030"
             note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
                      pdf.fill_color "000000"
end
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      for part in @parts
                    parts = [[{:text => "PART #{part.id} - #{part.name.upcase}", :font_style => :bold}]]
                    pdf.table parts, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 380},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                    pdf.move_down(5)
                    articles = StandardPartArticle.part_id_eq(part.id).standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      note = [[{:text => "#{article.note}"}]]
                      pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0

                      pdf.fill_color "000000"
                      unless article.note.blank?
                        pdf.move_down(5)
                      end
end
                      articles = [[{:text => "#{part.id}.#{report_article_number(a)}", :font_style => :bold},{:text => article.article.name.upcase, :font_style => :bold}]]
                      pdf.table articles, :font_size => 9, :style => :bold,
                       :column_widths => {0 => 35, 1 => 425},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 97
                      c = 1
                      for paragraph in article.standard_article_paragraphs
                      d = 1
 if @admin_format.show_notes
                      pdf.fill_color "309030"
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                       note = [[{:text => "#{paragraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                      unless paragraph.note.blank?
                        pdf.move_down(5)
                      end
                      pdf.fill_color "000000"
end
                        for subparagraph in paragraph.standard_subparagraphs
 if @admin_format.show_notes
                        pdf.fill_color "309030"
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                        note = [[{:text => "#{subparagraph.note}"}]]
                        pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
                        unless subparagraph.note.blank?
                        pdf.move_down(5)
                        end
                          pdf.fill_color "000000"
end
                          if d == 1
                            d = d + 1
                            subparagraphs = [["",".#{c}","#{paragraph.paragraph.name}: #{subparagraph.description}"]]
                          else
                            subparagraphs = [["",".#{c}",subparagraph.description]]
                          end

                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 35, 1 => 25, 2 => 395},
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
 if @admin_format.show_notes
            unless @standard_section_note.blank? || @standard_section_note.description.blank?
                 pdf.move_down(10)
                 pdf.fill_color "309030"
                note = [[{:text => "#{@standard_section_note.description}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 460},
                        :position => :left,
                        :vertical_padding => 2,
                        :border_width  => 0
            end

          pdf.fill_color "000000"
end
          pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold

          end

          else
                   pdf.fill_color "309030"
                   note = [[{:text => "#{@standard_section.comments}"}]]
                    pdf.table note, :font_size => 9, :style => :bold,
                    :column_widths => {0 => 460},
                    :position => :left,
                    :vertical_padding => 2,
                    :border_width  => 0
                      pdf.move_down(5)
                      pdf.fill_color "000000"
                      pdf.text "SECTION #{@standard_section.section.modif_number}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                      pdf.text "#{@standard_section.section.name.upcase}", :align => :center, :size => 9, :style => :bold
                      pdf.move_down(5)
                    articles = StandardUserArticle.standard_section_id_eq(@standard_section.id)
                    a = 1
                    for article in articles
                      articles = [[{:text => article.name.upcase, :font_style => :bold}]]                      
                      pdf.table articles, :font_size => 9, :style => :bold,
                      :column_widths => {0 => 460},
                      :position => :left,
                      :vertical_padding => 2,
                      :border_width       => 0
                      pdf.move_down(5)
                      b = 97
                      for paragraph in article.standard_user_paragraphs
                        paragraphs = [["","#{b.chr.upcase}.",paragraph.paragraph]]
                        pdf.table paragraphs, :font_size => 9, :style => :bold,
                        :column_widths => {0 => 0, 1 => 20, 2 => 460},
                        :position => :left,
                        :vertical_padding => 1,
                        :border_width       => 0
                        pdf.move_down(5)
                        c = 1
                        for subparagraph in paragraph.standard_user_subparagraphs
                          subparagraphs = [["","#{c}.",subparagraph.description]]
                          pdf.table subparagraphs, :font_size => 9, :style => :bold,
                          :column_widths => {0 => 20, 1 => 25, 2 => 435},
                          :inline_format => true,
                          :position => :left,
                          :vertical_padding => 1,
                          :border_width       => 0,
                          :align => {2 => :left}

                          c += 1
                        end
                        pdf.move_down(5)
                        b += 1
                  end
           end

           pdf.move_down(10)
          pdf.text "END OF SECTION", :align => :center, :size => 9, :style => :bold

         end


end

          pdf.page_count.times do |i|
              pdf.go_to_page(i+1)
              pdf.lazy_bounding_box([pdf.bounds.right - 265, pdf.bounds.bottom + 70], :width =>250, :align => :right) {
                 pdf.fill_color "000000"
                 pdf.text "#{@standard_section.choose_option(@admin_format.bottom_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@standard_section.choose_option(@admin_format.bottom_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@standard_section.choose_option(@admin_format.bottom_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 5, pdf.bounds.bottom + 70], :width => 250, :align => :left) {
                 pdf.fill_color "000000"
                 pdf.text "#{@standard_section.choose_option(@admin_format.bottom_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@standard_section.choose_option(@admin_format.bottom_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@standard_section.choose_option(@admin_format.bottom_left_3, pdf)}", :size => 9, :align => :left
              }.draw


              pdf.lazy_bounding_box([pdf.bounds.right - 240, pdf.bounds.top], :width =>250, :align => :right) {
                pdf.fill_color "000000"
                 pdf.text "#{@standard_section.choose_option(@admin_format.top_right_1, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@standard_section.choose_option(@admin_format.top_right_2, pdf)}", :size => 9, :align => :right
                 pdf.text "#{@standard_section.choose_option(@admin_format.top_right_3, pdf)}", :size => 9, :align => :right
              }.draw

              pdf.lazy_bounding_box([pdf.bounds.left + 5, pdf.bounds.top], :width =>250, :align => :left) {
                 pdf.fill_color "000000"
                 pdf.text "#{@standard_section.choose_option(@admin_format.top_left_1, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@standard_section.choose_option(@admin_format.top_left_2, pdf)}", :size => 9, :align => :left
                 pdf.text "#{@standard_section.choose_option(@admin_format.top_left_3, pdf)}", :size => 9, :align => :left

              }.draw
          end