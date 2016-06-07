FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { Faker::Internet.password 10, 20 }
    password_confirmation { password }
    role User.roles[:user]

    User.roles.each do |k, v|
      trait k.to_sym do
        role v
      end
    end
  end
end
