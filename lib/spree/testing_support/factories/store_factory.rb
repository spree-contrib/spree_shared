FactoryGirl.define do
  factory :store, :class => Spree::Store do
    sequence(:name) { |n| "Test Store ##{n}" }
    sequence(:subdomain) { |n| "test#{n}" }

    factory :store_with_schema do
      after(:create) do |store|
        store.create_schema
      end
    end
  end
end
