class MemberWorklog < ApplicationRecord
  belongs_to :organization
  belongs_to :membership

  # Constants for worklog types
  WORKLOG_TYPES = {
    work: 'work',
    vacation: 'vacation',
    sick: 'sick'
  }.freeze

  # Validations
  validates :date, presence: true
  
  # Ensure only one entry per day per user
  validates :date, uniqueness: { scope: :membership_id, message: "already has a worklog entry" }

  # Use a more descriptive column name for external interface
  def worklog_type
    type
  end
  
  def worklog_type=(value)
    self.type = value
  end

  # Duration is fixed at 8 hours (1 working day)
  def duration
    8
  end

  # Scopes for different worklog types
  scope :work_days, -> { where(type: WORKLOG_TYPES[:work]) }
  scope :vacation_days, -> { where(type: WORKLOG_TYPES[:vacation]) }
  scope :sick_days, -> { where(type: WORKLOG_TYPES[:sick]) }
end


