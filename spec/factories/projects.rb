FactoryBot.define do
  factory :project do
    name { Faker::Book.title }

    trait :invalid do
      name nil
    end
  end
end
