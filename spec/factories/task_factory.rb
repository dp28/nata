FactoryGirl.define do
  factory :task do
    sequence(:content) { |n| "Task #{n}" }
    user

    factory :completed_task do
      completed true
    end
  end
end