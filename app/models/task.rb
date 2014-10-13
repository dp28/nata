class Task < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true

  scope :incomplete, -> { where completed: false }
end
