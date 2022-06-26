# frozen_string_literal: true

User.create(email: 'test@nulp.ua', password: '123456')

Product.create(name: 'Awesome T-Shirt', price_cents: 3000)
Product.create(name: 'Awesome Sneakers', price_cents: 5000)

Product.create(price_cents: 10_000, name: 'Premium Plan', stripe_plan_name: 'premium-plan')

req = Rails.env.production? ? ActionDispatch::Request.new('HTTP_HOST' => 'api-integration-app.herokuapp.com') : ActionDispatch::Request.new('HTTP_HOST' => 'localhost:3000') # rubocop:disable Layout/LineLength
plan = PayPal::SDK::REST::Plan.new({
                                     name: 'Premium Plan',
                                     description: 'Premium Plan',
                                     type: 'fixed',
                                     payment_definitions: [{
                                       name: 'Premium Plan',
                                       type: 'REGULAR',
                                       frequency_interval: '1',
                                       frequency: 'MONTH',
                                       cycles: '12',
                                       amount: {
                                         currency: 'USD',
                                         value: '100.00'
                                       }
                                     }],
                                     merchant_preferences: {
                                       cancel_url: "#{req.url}/",
                                       return_url: "#{req.url}/",
                                       max_fail_attempts: '0',
                                       auto_bill_amount: 'YES',
                                       initial_fail_amount_action: 'CONTINUE'
                                     }
                                   })
plan.create
plan_update = {
  op: 'replace',
  path: '/',
  value: {
    state: 'ACTIVE'
  }
}
plan.update(plan_update)
Product.last.update(paypal_plan_name: plan.id)
