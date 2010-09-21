class AdminFormatsController < ApplicationController
  before_filter :login_required
  access_control do
    allow :admin
    allow :manager, :except => [:destroy]
  end
  def edit
    
    admin_format = AdminFormat.user_id_eq(User.find(as_user).admin_format.id)
    
  end
  
  def update
    @admin_format = AdminFormat.find(User.find(as_user).admin_format.id)
    params[:admin_format][:top_left_1] = params["tp_left_1"] if params["chk_1"] == "1"
    params[:admin_format][:top_left_2] = params["tp_left_2"] if params["chk_2"] == "1"
    params[:admin_format][:top_left_3] = params["tp_left_3"] if params["chk_3"] == "1"
    params[:admin_format][:top_right_1] = params["tp_right_1"] if params["chk_4"] == "1"
    params[:admin_format][:top_right_2] = params["tp_right_2"] if params["chk_5"] == "1"
    params[:admin_format][:top_right_3] = params["tp_right_3"] if params["chk_6"] == "1"
    params[:admin_format][:bottom_left_1] = params["bt_left_1"] if params["chk_7"] == "1"
    params[:admin_format][:bottom_left_2] = params["bt_left_2"] if params["chk_8"] == "1"
    params[:admin_format][:bottom_left_3] = params["bt_left_3"] if params["chk_9"] == "1"
    params[:admin_format][:bottom_right_1] = params["bt_right_1"] if params["chk_10"] == "1"
    params[:admin_format][:bottom_right_2] = params["bt_right_2"] if params["chk_11"] == "1"
    params[:admin_format][:bottom_right_3] = params["bt_right_3"] if params["chk_12"] == "1"
    if params["restore"] == "1"
      params[:admin_format][:top_left_1] = "job no"
      params[:admin_format][:top_left_2] = "date"
      params[:admin_format][:top_left_3] = ""
      params[:admin_format][:top_right_1] = "job name"
      params[:admin_format][:top_right_2] = "job location"
      params[:admin_format][:top_right_3] = ""
      params[:admin_format][:bottom_left_1] = "section author"
      params[:admin_format][:bottom_left_2] = ""
      params[:admin_format][:bottom_left_3] = ""
      params[:admin_format][:bottom_right_1] = "section name"
      params[:admin_format][:bottom_right_2] ="section no"
      params[:admin_format][:bottom_right_3] = "page no"
    end
   
    if @admin_format.update_attributes(params[:admin_format])
      @admin_format.show_notes = params[:admin_format][:show_notes]
      @admin_format.save
      flash[:notice] = "Successfully updated admin format."
      redirect_to change_format_path
    else
      render :action => 'edit'
    end
  end
  
  
  def change_format
    @admin_format = AdminFormat.find(User.find(as_user).admin_format.id)
    render :action => "edit"
  end
end
