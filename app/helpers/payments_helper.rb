module PaymentsHelper
  require 'money_utils'
  def cents_to_currency(cents, currency = "USD")
    MoneyUtils.format(cents, currency)
  end
end
