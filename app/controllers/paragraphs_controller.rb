class ParagraphsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :support
  end
  def index
    @paragraphs = Paragraph.all(:conditions => "article_id = #{params[:art_id]} and part_id = #{params[:part_id]}")
    
  end
  
  def show
    @paragraph = Paragraph.find(params[:id])
  end
  
  def new
    @paragraph = Paragraph.new(:part_id => params[:part_id], :article_id => params[:art_id])
  end
  
  def create
    @paragraph = Paragraph.new(params[:paragraph])
    @paragraph.article_id = params[:art_id]
    if @paragraph.save
      flash[:notice] = "Successfully created paragraph."
      redirect_to paragraphs_path(:part_id => @paragraph.part_id, :art_id => params[:art_id])
    else
      render :action => 'new'
    end
  end
  
  def edit
    @paragraph = Paragraph.find(params[:id])
  end
  
  def update
    @paragraph = Paragraph.find(params[:id])
    params[:paragraph][:article_id] = params[:art_id]
    if @paragraph.update_attributes(params[:paragraph])
      flash[:notice] = "Successfully updated paragraph."
      redirect_to "/paragraphs?art_id=#{params[:art_id]}&part_id=#{params[:part_id]}"
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @paragraph = Paragraph.find(params[:id])
    @paragraph.destroy
    flash[:notice] = "Successfully removed paragraph."
    redirect_to "/paragraphs?art_id=#{params[:art_id]}&part_id=#{params[:part_id]}"
  end
end
