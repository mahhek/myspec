class JobPageFormatsController < ApplicationController
  def edit
    #@job_page_format = JobPageFormat.first
  end
  
  def update
    @job = Job.find(params[:job_id])
    #@job.layout_id = params[:job][:layout_id]
   # @job.save
    
    @job_page_format = JobPageFormat.find(params[:id])
    params[:job_page_format][:top_left_1] = params["tp_left_1"] if params["chk_1"] == "1"
    params[:job_page_format][:top_left_2] = params["tp_left_2"] if params["chk_2"] == "1"
    params[:job_page_format][:top_left_3] = params["tp_left_3"] if params["chk_3"] == "1"
    params[:job_page_format][:top_right_1] = params["tp_right_1"] if params["chk_4"] == "1"
    params[:job_page_format][:top_right_2] = params["tp_right_2"] if params["chk_5"] == "1"
    params[:job_page_format][:top_right_3] = params["tp_right_3"] if params["chk_6"] == "1"
    params[:job_page_format][:bottom_left_1] = params["bt_left_1"] if params["chk_7"] == "1"
    params[:job_page_format][:bottom_left_2] = params["bt_left_2"] if params["chk_8"] == "1"
    params[:job_page_format][:bottom_left_3] = params["bt_left_3"] if params["chk_9"] == "1"
    params[:job_page_format][:bottom_right_1] = params["bt_right_1"] if params["chk_10"] == "1"
    params[:job_page_format][:bottom_right_2] = params["bt_right_2"] if params["chk_11"] == "1"
    params[:job_page_format][:bottom_right_3] = params["bt_right_3"] if params["chk_12"] == "1"
    if params["restore"] == "1"
      @admin_format = AdminFormat.find(current_user.admin_format.id)
      params[:job_page_format][:top_left_1] = @admin_format.top_left_1
      params[:job_page_format][:top_left_2] = @admin_format.top_left_2
      params[:job_page_format][:top_left_3] = @admin_format.top_left_3
      params[:job_page_format][:top_right_1] = @admin_format.top_right_1
      params[:job_page_format][:top_right_2] = @admin_format.top_right_2
      params[:job_page_format][:top_right_3] = @admin_format.top_right_3
      params[:job_page_format][:bottom_left_1] = @admin_format.bottom_left_1
      params[:job_page_format][:bottom_left_2] = @admin_format.bottom_left_2
      params[:job_page_format][:bottom_left_3] = @admin_format.bottom_left_3
      params[:job_page_format][:bottom_right_1] = @admin_format.bottom_right_1
      params[:job_page_format][:bottom_right_2] = @admin_format.bottom_right_2
      params[:job_page_format][:bottom_right_3] = @admin_format.bottom_right_3
    end
    if @job_page_format.update_attributes(params[:job_page_format])
      flash[:notice] = "Successfully updated job page format."
      redirect_to change_job_page_format_path(:job_id => @job_page_format.job.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @job_page_format = JobPageFormat.find(params[:id])
    @job_page_format.destroy
    flash[:notice] = "Successfully destroyed job page format."
    redirect_to job_page_formats_url
  end
  
  def change_format
   @job_page_format = JobPageFormat.find(Job.find(params[:job_id]).job_page_format)
   @job = @job_page_format.job
   @client = @job.client
    render :action => "edit"
  end
end
