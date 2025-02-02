json.extract! employee, :id, :organization_id, :membership_id, :created_at, :updated_at
json.url employee_url(employee, format: :json)
