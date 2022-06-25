# frozen_string_literal: true

Product.create(name: 'Awesome T-Shirt', price_cents: 3000)
Product.create(name: 'Awesome Sneakers', price_cents: 5000)

Product.create(price_cents: 10_000, name: 'Premium Plan', stripe_plan_name: 'premium-plan')
