FactoryBot.define do
  factory :run do
    association :race
    association :user
    date { Date.current }
    time { 3600 }
    # nil lets the set_defaults_from_race before_validation callback inherit from the race
    distance { nil }
  end
end
