json.extract! membership_worklog, :id, :organization_id, :membership_id, :date, :check_in, :check_out, :created_at, :updated_at
json.url membership_worklog_url(membership_worklog, format: :json)
