FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    role User.roles[:user]

    User.roles.each do |k, v|
      trait k.to_sym do
        role v
      end
    end
  end
end
