FactoryBot.define do
  factory :race do
    sequence(:name) { |n| "Race #{n}" }
    location { "Madrid" }
    distance { 10.0 }
    homologated { true }
    # user_id is set directly until belongs_to :user is added in Phase 1
    user_id { create(:user).id }
  end
end
