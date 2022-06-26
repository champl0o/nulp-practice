# frozen_string_literal: true

# I would wrap it in some abstraction like PaymentProvider::Paypal::Orders but I would leave it as it is because of
# the guide I`m following
class Orders::Paypal # rubocop:disable Style/ClassAndModuleChildren
  def self.finish(charge_id)
    order = Order.paypal_executed.find_by(charge_id: charge_id)
    return nil if order.nil?

    order.set_paid
    order
  end

  def self.create_payment(order:, product:) # rubocop:disable Metrics/MethodLength
    payment_price = (product.price_cents / 100.0).to_s
    currency = 'USD'
    payment = PayPal::SDK::REST::Payment.new({
                                               intent: 'sale',
                                               payer: {
                                                 payment_method: 'paypal'
                                               },
                                               redirect_urls: {
                                                 return_url: '/',
                                                 cancel_url: '/'
                                               },
                                               transactions: [{
                                                 item_list: {
                                                   items: [{
                                                     name: product.name,
                                                     sku: product.name,
                                                     price: payment_price,
                                                     currency: currency,
                                                     quantity: 1
                                                   }]
                                                 },
                                                 amount: {
                                                   total: payment_price,
                                                   currency: currency
                                                 },
                                                 description: "Payment for: #{product.name}"
                                               }]
                                             })
    if payment.create # rubocop:disable Style/GuardClause
      order.token = payment.token
      order.charge_id = payment.id
      return payment.token if order.save
    end
  end

  def self.execute_payment(payment_id:, payer_id:)
    order = Order.find_by(charge_id: payment_id)
    return false unless order

    payment = PayPal::SDK::REST::Payment.find(payment_id)
    if payment.execute(payer_id: payer_id) # rubocop:disable Style/GuardClause
      order.set_paypal_executed
      order.save
    end
  end

  def self.create_subscription(order:, product:) # rubocop:disable Metrics/MethodLength
    agreement = PayPal::SDK::REST::Agreement.new({
                                                   name: product.name,
                                                   description: "Subscription for: #{product.name}",
                                                   start_date: (Time.now.utc + 1.minute).iso8601,
                                                   payer: {
                                                     payment_method: 'paypal'
                                                   },
                                                   plan: {
                                                     id: product.paypal_plan_name
                                                   }
                                                 })
    if agreement.create # rubocop:disable Style/GuardClause
      order.token = agreement.token
      return agreement.token if order.save
    end
  end

  def self.execute_subscription(token:)
    order = Order.recently_created.find_by(token: token)
    return false unless order

    agreement = PayPal::SDK::REST::Agreement.new
    agreement.token = token
    if agreement.execute  # rubocop:disable Style/GuardClause
      order.charge_id = agreement.id
      order.set_paypal_executed
      return order.charge_id if order.save
    end
  end
end