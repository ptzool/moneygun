class TaskCategory < ApplicationRecord
  # Associations
  belongs_to :organization
  has_many :tasks, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered_by_name, -> { order(:name) }

  # Callbacks
  before_validation :set_default_color, if: -> { color.blank? }

  private

  def set_default_color
    self.color = generate_random_color
  end

  def generate_random_color
    "##{SecureRandom.hex(3)}"
  end
end