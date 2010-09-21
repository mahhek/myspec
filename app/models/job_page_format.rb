class JobPageFormat < ActiveRecord::Base
  #attr_accessible :job_id, :top_left_1, :top_left_2, :top_left_3, :top_right_1, :top_right_2, :top_right_3, :bottom_left_1, :bottom_left_2, :bottom_left_3, :bottom_right_1, :bottom_right_2, :bottom_right_3
  belongs_to :job
  belongs_to :layout
  
  # def options
  #     options = ["job no","date", "job name", "job location", "section author", "section name", "section no", "page no"]
  #   end
  #   
  #   def choose_option(option)
  #     if (options.include?(option))
  #       if option == "job no"
  #         choosen = self.job.number
  #       elsif option == "date"
  #         choosen = Time.now.strftime("%m-%d-%Y")
  #       elsif option == "job name"
  #         choosen = self.job.name
  #       elsif option == "job location"
  #         choosen = ""
  #       elsif option == "section author"
  #         choosen = ""
  #       elsif option == "section name"
  #         choosen = ""
  #       elsif option == "section no"
  #         choosen = ""
  #       elsif option == "page no"
  #         choosen = ""
  #       end
  #     else
  #       choosen = option
  #     end
  #     return choosen.to_s
  #   end
end
