json.extract! employee_document, :id, :organization_id, :employee_id, :created_at, :updated_at
json.url employee_document_url(employee_document, format: :json)
