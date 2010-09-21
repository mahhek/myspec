pdf.font "Helvetica"

pdf.table [[{:text => "Project Manual Table of Contents", :font_style => :bold}]], :font_size => 12, :style => :bold,
  :column_widths => {0 => 350},
  :position => :left,
  :vertical_padding => 2,
  :border_width       => 0
pdf.move_down(30)
header = [
  ["Project:",@job.name],
  ["",@job.client.physical_address],
  ["",@job.client.postal_address],
  ["",""],
  ["Owner:",@job.client.name],
  ["",""],
  ["",""],
  ["",""],
  ["",""],
  [{:text => @job.number, :font_style => :bold},""]
  ]
pdf.table header, :font_size => 9, :style => :bold,
  :column_widths => {0 => 70, 1 => 340},
  :position => :left,
  :vertical_padding => 2,
  :border_width       => 0
pdf.move_down(20)

header = [[{:text => "Number", :font_style => :bold},{:text => "Title", :font_style => :bold},{:text => "Pages", :font_style => :bold}]]
pdf.table header, :font_size => 9, :font_style => :bold_italyc,
  :column_widths => {0 => 50, 1 => 340, 2 => 40},
  :position => :left,
  :vertical_padding => 2,
  :align => {0 => :left, 1 => :center},
  :border_width       => 0
  
pdf.move_down(10)
for specification in @job.specifications
  #pdf.text "DIVISION #{specification.division.search_number} - #{specification.division.name}".upcase, :style => :bold, :size => 9
  title = [[{:text => specification.division.modif_number, :font_style => :bold},{:text => specification.division.name, :font_style => :bold}]]
  pdf.table title, :font_size => 9, :font_style => :bold,
    :column_widths => {0 => 65, 1 => 340},
    :position => :left,
    :vertical_padding => 2,
    :border_width       => 0
  
  if(!specification.specification_sections.blank?)
    items = specification.specification_sections.map do |item|
      [
        item.section.modif_number,
        item.section.name,
      ]
    end
  
    pdf.table items, :font_size => 9,
      :border_style => :grid,
      :column_widths => {0 => 65, 1 => 340},
      :position => :left,
      :vertical_padding => 2,
      :border_width       => 0
  end
end