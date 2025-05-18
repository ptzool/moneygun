json.extract! task_timetracking, :id, :task_id, :membership_id, :date, :start, :end, :duration, :created_at, :updated_at
json.url task_timetracking_url(task_timetracking, format: :json)
