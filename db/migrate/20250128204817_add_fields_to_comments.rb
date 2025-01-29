class AddFieldsToComments < ActiveRecord::Migration[8.0]
  def change
    add_reference :comments, :task, null: false, foreign_key: true
  end
end
