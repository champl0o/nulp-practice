# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :user, factory: :user
    association :product, factory: :product
  end
end
