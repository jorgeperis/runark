FactoryBot.define do
  factory :run_mark do
    association :race
    sequence(:edition) { |n| n }
    date { Date.current }
    time { 3600 }
    source { "chip" }
    # nil lets the set_defaults_from_race before_validation callback inherit from the race
    distance { nil }
    homologated { nil }

    # user_id mirrors the race until belongs_to :user is added in Phase 1
    after(:build) { |run_mark| run_mark.user_id ||= run_mark.race&.user_id }
  end
end
