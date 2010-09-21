class ImportsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow logged_in
  end
  
  def new
    @import = Import.new
  end
  
  def create
    @import = Import.new(params[:import])
    respond_to do |format|
      if @import.save!
        flash[:notice] = "Data successfully imported"
        format.html {redirect_to(@import)}
      else
        flash[:error] = "Import failed"
        format.html {render :action => "new"}
      end
    end
  end
  
  def show
    @import = Import.find(params[:id])
  end
  
  def proc_csv
    @import = Import.find(params[:id])
    lines = parse_csv_file(@import.csv.path)
    #lines.shift
    if lines.size > 0
      @import.processed = lines.size
      lines.each do |line|
        case @import.datatype
        when "releases"
          new_release(line)
        end
      end
      @import.save
      flash[:notice] = "Data processing was successful"
      redirect_to import_path(@import)
    else
      flash[:error] = "Data processing failed"
      render :action => "show", :id => @import.id
    end
  end
  
  private
  
  def parse_csv_file(path_to_csv)
    lines = []
    
    require 'fastercsv'
    
    FasterCSV.foreach(path_to_csv) do |row|
      lines << row
    end
    lines
  end
  
  def new_release(line)
    params = Hash.new
    params[:release] = Hash.new
    params[:release]["divID"] = line[0]
    params[:release]["divName"] = line[1]
    #params[:release]["description"] = line[2]
    #params[:release]["notes"] = line[4]
    release = Release.new(params[:release])
    release.save
  end
end
