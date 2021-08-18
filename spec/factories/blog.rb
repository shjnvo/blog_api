FactoryBot.define do
  factory :blog do
    sequence(:title) { |n| "some title #{n}" }
    content { 'some content' }
  end
end