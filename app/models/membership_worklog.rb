class MembershipWorklog < ApplicationRecord
  belongs_to :organization
  belongs_to :membership

  enum :type, { low: "low", medium: "medium", high: "high" }

  extend SimpleCalendar
end
