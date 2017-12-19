FactoryBot.define do
  factory :task do
    title { Faker::Food.ingredient }
    association :project

    trait :invalid do
      title nil
    end
  end
end
