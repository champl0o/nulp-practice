# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root 'orders#index'
  post 'orders/submit', to: 'orders#submit'
  post 'orders/paypal/create_payment', to: 'orders#paypal_create_payment', as: :paypal_create_payment
  post 'orders/paypal/execute_payment', to: 'orders#paypal_execute_payment', as: :paypal_execute_payment
  post 'orders/paypal/create_subscription', to: 'orders#paypal_create_subscription', as: :paypal_create_subscription
  post 'orders/paypal/execute_subscription', to: 'orders#paypal_execute_subscription', as: :paypal_execute_subscription
end
