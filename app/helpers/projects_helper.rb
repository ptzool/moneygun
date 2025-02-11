module ProjectsHelper
  def archive_badge_color(archived)
    case archived
    when false
      "text-green-600 bg-green-100"
    when true
      "text-red-600 bg-red-100"
    end
  end
end
