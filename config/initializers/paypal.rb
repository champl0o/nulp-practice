# frozen_string_literal: true

PayPal::SDK.configure(
  mode: ENV['PAYPAL_ENV'],
  client_id: ENV['PAYPAL_CLIENT_ID'],
  client_secret: ENV['PAYPAL_CLIENT_SECRET']
)
PayPal::SDK.logger.level = Logger::INFO

module PayPal
  module SDK
    module Core
      module Util
        module HTTPHelper
          def default_ca_file
            nil # packaged CA file was out of date, use the system file
          end
        end
      end
    end
  end
end
