class CreateRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :update_request_requests do |t|
      t.belongs_to :updateable, polymorphic: true
      t.belongs_to :requester, polymorphic: true
      t.belongs_to :approver, polymorphic: true

      t.text :update_schema
      t.boolean :applied, null: false, default: false
      t.timestamps null: false
    end
  end
end
