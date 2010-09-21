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
               # @ccf = CloudFiles::Connection.new('odcastillo','eaa66061436e532c147163f7c9b523a4')
                #container = @ccf.container('development')

               # @attachments = SectionAttachment.specification_section_id_eq(item.id)
                #get all attachments
                i = 1
               # for attachment in @attachments
               #   object = container.object(attachment.asset.path)
                #  tmp = File.open(dir + "/"+attachment.specification_section.section.number.to_s+"-"+i.to_s+".pdf", "w+")
                #  tmp.syswrite(object.data)
                #  i += 1
               # end
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