FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    activated true
    activated_at Time.now
    
    factory :admin do
      admin true
    end

    factory :unauthenticated_user do
      activated false
      activated_at nil
    end
  end
end