FactoryGirl.define do
  factory :like do
    post { create :post, :with_user }
    trait :with_user do
      user { create :user }
    end
  end
end
