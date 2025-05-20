class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members

  validates :first_name, presence: false
  validates :last_name, presence: false

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
