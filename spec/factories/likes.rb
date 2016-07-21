FactoryGirl.define do
  factory :like do
  	post { create :post, :with_user }
    trait :with_user do
      user { create :user }
    end
    # trait :with_post do
    #   post { create :post, author: author}
    # end
  end
end