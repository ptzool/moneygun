json.extract! member_worklog, :id, :organization_id, :membership_id, :date, :type, :created_at, :updated_at
json.url member_worklog_url(member_worklog, format: :json)
