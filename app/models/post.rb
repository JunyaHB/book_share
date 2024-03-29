class Post < ApplicationRecord
	validates :book_title, {presence: true}
	validates :book_message, {presence: true}
	validates :user_id, {presence: true}

	def user
    	return User.find_by(id: self.user_id)
  	end
  	
end
