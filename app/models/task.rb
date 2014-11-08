class Task < ActiveRecord::Base
  belongs_to :user
  has_ancestry
  after_create    :add_to_users_lists
  before_destroy  :handle_destroy
  
  validates :user_id, presence: true
  validates :content, presence: true

  scope :incomplete,        -> { where completed: false }
  scope :complete,          -> { where completed: true  }
  scope :without_children,  -> { where is_leaf:   true  }

  def complete!
    update_attribute :completed, true
  end

  def uncomplete!
    update_attribute :completed, false
  end

  def add_task params={}    
    task = children.build params
    task.user = user
    update_attribute :is_leaf, false
    task
  end

  def lists 
    children.where is_leaf: false
  end

  def destroy
    children.each(&:destroy)    
    super
  end

  protected

    def task_about_to_be_deleted task
      update_attribute(:is_leaf, true) if children.to_a == [task]
    end

  private 

    def add_to_users_lists
      self.parent = user.root_list if parent.nil? && user.root_list != self
      true
    end

    def handle_destroy
      parent.task_about_to_be_deleted(self) if !root?
      true
    end
end
