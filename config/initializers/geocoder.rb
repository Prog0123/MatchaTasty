Geocoder.configure(
  # Geocoding options
  timeout: 5,                 # geocoding service timeout (secs)
  lookup: :google,            # name of geocoding service (symbol)
  api_key: Rails.application.credentials.dig(:google_maps, :api_key),
  use_https: true,           # use HTTPS for lookup requests? (if supported)

  # Calculation options
  units: :km,                # :km for kilometers or :mi for miles

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  always_raise: :all,

  # 日本語対応
  language: :ja
)
