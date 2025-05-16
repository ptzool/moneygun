class AddIndexesToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_index :organizations, :name
    add_index :organizations, :email
    add_index :organizations, :registration_number
    add_index :organizations, :tax_number
    
    # Add counter_cache columns
    add_column :organizations, :projects_count, :integer, default: 0, null: false
    add_column :organizations, :memberships_count, :integer, default: 0, null: false
    add_column :organizations, :tasks_count, :integer, default: 0, null: false

    # Update existing counts
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE organizations
          SET projects_count = (
            SELECT COUNT(id)
            FROM projects
            WHERE projects.organization_id = organizations.id
          )
        SQL
        
        execute <<-SQL
          UPDATE organizations
          SET memberships_count = (
            SELECT COUNT(id)
            FROM memberships
            WHERE memberships.organization_id = organizations.id
          )
        SQL
        
        execute <<-SQL
          UPDATE organizations
          SET tasks_count = (
            SELECT COUNT(id)
            FROM tasks
            WHERE tasks.organization_id = organizations.id
          )
        SQL
      end
    end
  end
end