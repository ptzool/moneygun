class Comment < ApplicationRecord
  belongs_to :membership
  belongs_to :task, counter_cache: true

  validates :body, presence: true
  
  after_save :expire_task_cache
  after_destroy :expire_task_cache
  
  private
  
  def expire_task_cache
    # Frissítsük a task mutatásához használt cache-t
    task_updated_at = task.updated_at.to_i
    Rails.cache.delete(["task", task.id, "total_time_spent", task_updated_at])
    
    # Frissítsük a listázó cache-eket az új formátumban
    Rails.cache.delete_matched("organization_tasks/#{task.organization_id}*")
  end
end
