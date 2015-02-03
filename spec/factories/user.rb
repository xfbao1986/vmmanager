# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name "testuser"
    admin true
    email "testuser@**"
    password "password"
  end
end
