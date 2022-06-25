class Product < ApplicationRecord
  monetize :price_cents
  has_many :orders
end