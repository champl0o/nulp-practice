# frozen_string_literal: true

# I would wrap it in some abstraction like PaymentProvider::Stripe::Orders but I would leave it as it is because of
# the guide I`m following
class Orders::Stripe # rubocop:disable Style/ClassAndModuleChildren
  INVALID_STRIPE_OPERATION = 'Invalid Stripe Operation'
  def self.execute(order:, user:)
    product = order.product

    # Check if the order is a plan
    if product.stripe_plan_name.blank?
      charge = execute_charge(price_cents: product.price_cents,
                              description: product.name,
                              card_token: order.token)
    else
      customer = find_or_create_customer(card_token: order.token,
                                         customer_id: user.stripe_customer_id,
                                         email: user.email)
      if customer
        user.update(stripe_customer_id: customer.id)
        order.customer_id = customer.id
        charge = execute_subscription(plan: product.stripe_plan_name, customer: customer)
      end
    end

    if charge&.id.present?
      # If there is a charge with id, set order paid.
      order.charge_id = charge.id
      order.set_paid
    end
  rescue Stripe::StripeError
    # If a Stripe error is raised from the API,
    # set status failed and an error message
    order.error_message = INVALID_STRIPE_OPERATION
    order.set_failed
  end

  def self.execute_charge(price_cents:, description:, card_token:)
    Stripe::Charge.create({
                            amount: price_cents.to_s,
                            currency: 'usd',
                            description: description,
                            source: card_token
                          })
  end

  def self.execute_subscription(plan:, customer:)
    Stripe::Subscription.create({
                                  customer: customer.id,
                                  plan: plan
                                })
  end

  def self.find_or_create_customer(card_token:, customer_id:, email:)
    if customer_id
      stripe_customer = Stripe::Customer.retrieve({ id: customer_id })
      stripe_customer = Stripe::Customer.update(stripe_customer.id, { source: card_token }) if stripe_customer
    else
      stripe_customer = Stripe::Customer.create({
                                                  email: email,
                                                  source: card_token
                                                })
    end
    stripe_customer
  end
end
