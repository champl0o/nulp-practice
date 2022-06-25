# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root 'orders#index'
  post '/orders/submit', to: 'orders#submit'
end
