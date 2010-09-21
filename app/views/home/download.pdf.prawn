
# DOCUMENT-WIDE VARS
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

Prawn::Document.generate("flow_with_headers_and_footers.pdf")  do


#page_inside_border = [20,535]
page_inside_width = 480
page_inside_height = 700

#page_heading_size = 24
#heading_2_size = 14

#basic_padding = 20

pdf.bounding_box([0,0], :width => 480) do

   
    pdf.bounding_box([70, 680], :width => 350, :height => 600 ) do
        
           pdf.text "MATERIALS", :size => 8, :style => :bold, :align => :left
           pdf.move_down(10)
           pdf.text "A. Material of Type 3", :size => 8,:align => :left
           pdf.move_down(6)
           pdf.text "B. Material of type 3434", :size => 8,:align => :left
           pdf.move_down(10)
            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
            pdf.move_down(10)
             pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
             pdf.move_down(10)
              pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
              pdf.move_down(10)
               pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
               pdf.move_down(10)
                pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                pdf.move_down(10)
                 pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                 pdf.move_down(10)
                  pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                  pdf.move_down(10)
                   pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                   pdf.move_down(10)
                    pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                    pdf.move_down(10)
                     pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                     pdf.move_down(10)
                      pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                      pdf.move_down(10)
                       pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                       pdf.move_down(10)
                        pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                        pdf.move_down(10)
                         pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                         pdf.move_down(10)
                          pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                          pdf.move_down(10)
                           pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                           pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                    pdf.move_down(10)
                     pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                     pdf.move_down(10)
                      pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                      pdf.move_down(10)
                       pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                       pdf.move_down(10)
                        pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                        pdf.move_down(10)
                         pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                         pdf.move_down(10)
                          pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                          pdf.move_down(10)
                           pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                           pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                    pdf.move_down(10)
                     pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                     pdf.move_down(10)
                      pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                      pdf.move_down(10)
                       pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                       pdf.move_down(10)
                        pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                        pdf.move_down(10)
                         pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                         pdf.move_down(10)
                          pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                          pdf.move_down(10)
                           pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                           pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                    pdf.move_down(10)
                     pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                     pdf.move_down(10)
                      pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                      pdf.move_down(10)
                       pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                       pdf.move_down(10)
                        pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                        pdf.move_down(10)
                         pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                         pdf.move_down(10)
                          pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                          pdf.move_down(10)
                           pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
                           pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
pdf.move_down(10)
                            pdf.text "A. New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices New polices ", :size => 8,:align => :left
           

    end
    end


    


#end

pdf.page_count.times do |i|
    pdf.go_to_page(i+1)
    pdf.lazy_bounding_box([bounds.left+20, bounds.bottom + 50], :width =>100, :align => :right) {
       pdf.text "[AUTHOR]", :size => 9, :style => :bold, :align => :left
       pdf.text "[FILE NAME]", :size => 9, :style => :bold, :align => :left
    }.draw
    pdf.lazy_bounding_box([bounds.right-100, bounds.bottom + 50], :width =>100, :align => :right) {
       pdf.text "[AUTHOR]", :size => 9, :style => :bold, :align => :right
       pdf.text "[FILE NAME]", :size => 9, :style => :bold, :align => :right
    }.draw

    pdf.lazy_bounding_box([bounds.right-200, bounds.top + 40], :width =>200, :align => :right) {
       pdf.text "This is a long project name", :size => 9, :style => :bold, :align => :right
       pdf.text "This is a large description This is a large description This is a large description This is a large description ", :size => 9, :align => :right
    }.draw

    pdf.lazy_bounding_box([bounds.left + 10, bounds.top + 40], :width =>150, :align => :left) {
       pdf.text "This is a long project number", :size => 9, :style => :bold, :align => :left
       pdf.text "27th march 2009", :size => 9, :align => :left
    }.draw
    pdf.lazy_bounding_box([bounds.left + 10, bounds.top], :width =>500) {
            pdf.text "[SECTION 04 56 78]", :size => 9, :style => :bold, :align => :center
           pdf.text "[MASONRY MORTARING]", :size => 9, :style => :bold, :align => :center
    }.draw

pdf.lazy_bounding_box([bounds.left, bounds.top + 70], :width =>550) {
            pdf.stroke_bounds
    }.draw
pdf.lazy_bounding_box([bounds.left, bounds.bottom + 20], :width =>550) {
            pdf.stroke_bounds
    }.draw

 end



end