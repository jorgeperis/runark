FactoryBot.define do
  factory :race do
    sequence(:name) { |n| "Race #{n}" }
    location { "Madrid" }
    distance { 10.0 }
    homologated { true }
    association :user
  end
end
