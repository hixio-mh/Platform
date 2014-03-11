module AdefyPlatform
  module Jobs
    class MassPay

      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence { daily }

      def perform
        username  = AdefyPlatform::Config["paypal_classic_username"]
        password  = AdefyPlatform::Config["paypal_classic_password"]
        signature = AdefyPlatform::Config["paypal_classic_signature"]
        url       = AdefyPlatform::Config["paypal_classic_host"]

        paypal = Paypal.new(username, password, signature, :sandbox)

        payments = AdefyPlatform::User.find({}).map do |user|

          elapsed = Time.now = user["withdrawal"]["previousTimestamp"]
          rate = user["withdrawal"]["rateDays"] * (60 * 60 * 24)

          if elapsed >= rate and user["pubFunds"] >= user["withdrawal"]["min"]
            ppp = PayPalPayment.new
            ppp.email     = user["email"]
            ppp.unique_id = user["_id"]
            ppp.amount    = 0

            user["pubFunds"] = 0
            user.save

            ppp
          else
            null
          end

        end

        email_subject = nil # we aren't using this
        currency_code = "USD"
        receiver_type = "EmailAddress"

        paypal.do_mass_payment(payments, email_subject, receiver_type, currency_code)
      end

    end
  end
end
