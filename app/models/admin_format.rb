class AdminFormat < ActiveRecord::Base
  attr_accessible :layout_id, :user_id, :top_left_1, :top_left_2, :top_left_3, :top_right_1,:top_right_2,:top_right_3,:bottom_left_1,:bottom_left_2,:bottom_left_3,:bottom_right_1,:bottom_right_2,:bottom_right_3
  belongs_to :user
  belongs_to :layout

  
end
