FactoryGirl.define do
  factory :comment do
    content { Faker::Lorem.paragraph }
    #post { Faker::Lorem.sentence & Faker::Lorem.paragraph }

    trait :with_user do
      author { create :user }
    end
    trait :with_post do
      post {reate :post}
    end
  end
end
