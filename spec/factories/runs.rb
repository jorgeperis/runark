FactoryBot.define do
  factory :run do
    association :race
    date { Date.current }
    time { 3600 }
    # nil lets the set_defaults_from_race before_validation callback inherit from the race
    distance { nil }

    after(:build) { |run| run.user ||= run.race&.user }
  end
end
