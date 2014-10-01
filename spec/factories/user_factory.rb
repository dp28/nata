FactoryGirl.define do
  factory :user do
    name     "John Smith"
    email    "test@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end