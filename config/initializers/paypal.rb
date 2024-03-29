# We read the APP_CONFIG file ourselves to avoid imposing an order
# on the initializers.
raw_config = File.read(Rails.root.to_s + "/config/app_config.yml")
params = YAML.load(raw_config)[Rails.env].symbolize_keys

Paypal.setup do |config|
  
#  require 'paypal/orm/active_record'
  
  config.api_mode = params[:paypal_api_mode]
  config.api_username = params[:paypal_api_username]
  config.api_password = params[:paypal_api_password]
  config.api_signature = params[:paypal_api_signature]
  config.api_secret = params[:paypal_api_secret]
  config.application_id = params[:paypal_application_id]
  config.application_certificate = params[:application_certificate]
  config.application_key = params[:application_key]
  config.ipn_url = params[:paypal_ipn_url]
  config.return_url = params[:paypal_return_url]
  config.callback_url = params[:paypal_callback_url]
  config.cancel_url = params[:paypal_cancel_url]
  config.base_url = params[:paypal_base_url]
  config.api_base_url = params[:paypal_api_base_url]
end
