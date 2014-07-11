FactoryGirl.define do
  factory :user do
    name     "foo"
    email    "foo@exmaple.com"
    password "foobar"
    password_confirmation "foobar"
  end
end