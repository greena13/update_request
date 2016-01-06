class CreateUpdatedFiles < ActiveRecord::Migration
  def change
    create_table :update_request_updated_files do |t|
      t.belongs_to :request
      t.string :attribute_reference
      t.timestamps null: false
    end

    add_attachment :update_request_updated_files, :attachment
  end
end
