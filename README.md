# tik2tok-sdk
Build SDK for Tiktok API

## Installation

```bash
gem install tik2tok
```

## Usage

```ruby
require 'tik2tok'
```

## Configuration

```ruby
Tik2tok.configure do |config|
  config.client_key = "your_client_key"
  config.client_secret = "your_client_secret"
  config.redirect_uri = "your_redirect_uri"
  config.scope = "your_scope"
end
```

## Authorization

```ruby
Tik2tok.auth.authorize_url

# Rails using redirect_to
# Add allow_other_host: true to allow redirect to your own domain
redirect_to Tik2tok.auth.authorize_url, allow_other_host: true
```

## Access Token

```ruby
Tik2tok.auth.access_token(code: params[:code])
```

## Refresh Token

```ruby
Tik2tok.auth.refresh_token(refresh_token: params[:refresh_token])
```