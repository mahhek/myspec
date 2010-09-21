class CreditCardInformtaion < ActiveRecord::Base
  belongs_to :user

  def is_type(type)
    if type == self.card_type
      return "selected"
    else
      return ""
    end
  end
end
