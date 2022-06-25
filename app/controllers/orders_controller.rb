# frozen_string_literal: true

class OrdersController < ApplicationController
  SUCCESS_MESSAGE = 'Order Performed Successfully!'
  FAILURE_MESSAGE = 'Oops something went wrong. Please call the administrator'

  def index
    @products = Product.all
    @products_purchase = @products.where(stripe_plan_name: nil, paypal_plan_name: nil)
    @products_subscription = @products - @products_purchase
  end

  def submit # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    @order = nil
    # Check which type of order it is
    case order_params[:payment_gateway]
    when 'stripe'
      prepare_new_order
      Orders::Stripe.execute(order: @order, user: current_user)
    when 'paypal'
      # Paypal
    end
  ensure
    if @order&.save
      return render html: SUCCESS_MESSAGE if @order.paid?
      return render html: @order.error_message if @order.failed? && @order.error_message.present?
    end
    render html: FAILURE_MESSAGE
  end

  private

  # Initialize a new order and and set its user, product and price.
  def prepare_new_order
    @order = Order.new(order_params)
    @order.user_id = current_user.id
    @product = Product.find(@order.product_id)
    @order.price_cents = @product.price_cents
  end

  def order_params
    params.require(:orders).permit(:product_id, :token, :payment_gateway, :charge_id)
  end
end
