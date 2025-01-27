class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  include Transfer

  has_many :inboxes, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  has_one_attached :logo
end
