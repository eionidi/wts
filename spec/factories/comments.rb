FactoryGirl.define do
  factory :comment do
    content { Faker::Lorem.paragraph }
    post { create :post, :with_user }
   
    trait :with_user do
      author { create :user }
    end
    # trait :with_post do
    #   post { create :post, :with_user }
    # end
  end
end
