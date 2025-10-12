if Rails.env.production?
  ActionMailer::Base.add_delivery_method :sendgrid_actionmailer, SendGridActionMailer::DeliveryMethod,
    api_key: ENV["SENDGRID_API_KEY"]
end
