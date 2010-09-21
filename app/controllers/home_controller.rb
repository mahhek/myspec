class HomeController < ApplicationController
  #layout 'home'
  def index
    
  end
  
  def tour
    
  end
  
  def pricing_and_signup
    
  end
  
  def blog
    
  end
  
  def contact
    
  end
  
  def tes_pdf
    output = HelloReport.new.to_pdf

          respond_to do |format|
            format.pdf do
              send_data output, :filename => "hello.pdf", 
                                :type => "application/pdf"
            end
          end
  end
  
  def download
    prawnto :prawn => {
        :inline => true,
        :page_size => 'A4',
        :page_layout => :portrait,
        :left_margin => 20,
        :right_margin => 20,
        :top_margin => 20,
        :bottom_margin => 20
      }
      respond_to do |format|
        format.pdf  {
          render :layout => false
        }
      end
  end
end
