FactoryGirl.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    trait :with_user do
      author { create :user }
    end
  end
end
