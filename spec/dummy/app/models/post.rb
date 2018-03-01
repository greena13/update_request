class Post < ActiveRecord::Base
  validates :title, length: { minimum: 3 }

end
