module Tik2tok
  class Config
    attr_accessor :client_key, :client_secret, :redirect_uri, :scopes, :state

    def initialize(client_key: nil, client_secret: nil, redirect_uri: nil, scopes: ['user.info.basic'], state: nil)
      @client_key    = client_key
      @client_secret = client_secret
      @redirect_uri  = redirect_uri
      @scopes        = scopes
      @state         = state
    end

    def scopes_string
      return scopes if scopes.is_a?(String)
      scopes.join(',')
    end

    def csrf_state
      state || SecureRandom.hex(16)
    end

    def authorize_url
        "https://www.tiktok.com/v2/auth/authorize"
    end

    def authorize_params
      {
        client_key: client_key,
        scope: scopes_string,
        response_type: "code",
        redirect_uri: redirect_uri,
        state: csrf_state
      }
    end

    def authorize_token_url
      "https://open.tiktokapis.com/v2/oauth/token/"
    end

    def authorize_token_params(code: nil)
      {
        client_key: client_key,
        client_secret: client_secret,
        code: code,
				grant_type: "authorization_code",
        redirect_uri: redirect_uri
      }
    end

		def authorize_refresh_token_params(refresh_token: nil)
			{
				client_key: client_key,
				client_secret: client_secret,
				refresh_token: refresh_token,
				grant_type: "refresh_token"
			}
		end
  end
end