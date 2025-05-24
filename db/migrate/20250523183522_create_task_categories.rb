class CreateTaskCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :task_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :color
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :task_categories, [ :organization_id, :name ], unique: true
    add_index :task_categories, :active
  end
end
