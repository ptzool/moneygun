class AddTypeToMembershipWorklog < ActiveRecord::Migration[8.0]
  def change
    add_column :membership_worklogs, :type, :string
  end
end
