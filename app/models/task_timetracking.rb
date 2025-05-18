class TaskTimetracking < ApplicationRecord
  belongs_to :task, counter_cache: true
  belongs_to :membership

  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  after_save :expire_task_cache
  after_destroy :expire_task_cache
  
  # Methods for hour-based duration
  def duration_in_hours
    (duration.to_f / 60.0).round(1) if duration
  end
  
  def duration_in_hours=(hours)
    self.duration = (hours.to_f * 60).to_i if hours.present?
  end
  
  private
  
  def expire_task_cache
    # Használjunk egyszerűbb cache kulcsokat, amelyek nem okoznak serializációs problémát
    task_updated_at = task.updated_at.to_i
    Rails.cache.delete(["task", task.id, "total_time_spent", task_updated_at])
    Rails.cache.delete(["task", task.id, "total_time_spent_by_users", task_updated_at])
    
    # Frissítsük a listázó cache-eket az új formátumban
    Rails.cache.delete_matched("organization_tasks/#{task.organization_id}*")
  end
end
