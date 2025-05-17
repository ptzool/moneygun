module TasksHelper
  def priority_badge_color(priority)
    case priority.downcase
    when "high"
      "text-red-600 bg-red-100"
    when "medium"
      "text-yellow-600 bg-yellow-100"
    when "low"
      "text-green-600 bg-green-100"
    else
      "text-blue-600 bg-blue-100"
    end
  end

  def status_badge_color(status)
    case status.downcase
    when "closed"
      "text-green-600 bg-green-100"
    when "open"
      "text-red-600 bg-red-100"
    when "in_progress"
      "text-yellow-600 bg-yellow-100"
    else
      "text-blue-600 bg-blue-100"
    end
  end
end
