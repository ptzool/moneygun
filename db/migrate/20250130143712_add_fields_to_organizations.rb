class AddFieldsToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :address, :string
    add_column :organizations, :email, :string
    add_column :organizations, :registration_number, :string
    add_column :organizations, :tax_number, :string
    add_column :organizations, :iban, :string
  end
end
