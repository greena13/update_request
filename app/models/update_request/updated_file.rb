module UpdateRequest
  class UpdatedFile < ActiveRecord::Base
    include Paperclip::Glue

    belongs_to :request

    has_attached_file :attachment

    validates :request, :attachment, :attribute_reference, presence: true

    do_not_validate_attachment_file_type :attachment
  end
end
