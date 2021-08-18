FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Johnd #{n}" }
    sequence(:email) { |n| "person#{n}@example.com" }
    role { 'user' }
    password { '12345678' }
  end

  factory :admin, parent: :user do
    role { 'admin' }
  end
end