class MemberWorklog < ApplicationRecord
  belongs_to :organization
  belongs_to :membership
end
