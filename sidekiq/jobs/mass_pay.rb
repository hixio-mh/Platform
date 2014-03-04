module AdefyPlatform
  module Jobs
    class MassPay

      include Sidekiq::Worker

      def calc_withdrawal_amount(user)
        ad_amount = 0
        pub_amount = 0

        for withdrawal in user["pendingWithdrawals"]
          if withdrawal["source"] == "ad"
            ad_amount += withdrawal.amount
          elsif withdrawal["source"] == "pub"
            pub_amount += withdrawal.amount
          end
        end

        user_ad_funds = user["adFunds"]
        user_pub_funds = user["pubFunds"]
        ad_amount = 0 if ad_amount < 0
        ad_amount = user_ad_funds if ad_amount > user_ad_funds

        pub_amount = 0 if pub_amount < 0
        pub_amount = user_pub_funds if pub_amount > user_pub_funds

        return ad_amount + pub_amount
      end

      def perform
        paypal_config = AdefyPlatform::Config["paypal"]
        username  = paypal_config["username"]
        password  = paypal_config["password"]
        signature = paypal_config["signature"]
        url       = paypal_config["host"]

        paypal = Paypal.new(username, password, signature, url)

        payments = AdefyPlatform::User.all.map do |user|
          ppp = PayPalPayment.new
          ppp.email     = user["email"]
          ppp.unique_id = user["_id"]
          ppp.amount    = calc_withdrawal_amount(user)
          ppp
        end

        email_subject = nil # we aren't using this
        currency_code = "USD"
        receiver_type = "EmailAddress"

        paypal.do_mass_payment(payments, email_subject, receiver_type, currency_code)
      end

    end
  end
end