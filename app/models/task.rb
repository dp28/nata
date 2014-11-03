class Task < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true

  scope :incomplete,  -> { where completed: false }
  scope :complete,    -> { where completed: true }

  def complete!
    update_attribute :completed, true
  end

  def uncomplete!
    update_attribute :completed, false
  end
end
