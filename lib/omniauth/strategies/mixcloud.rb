require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class MixCloud < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'non-expiring'

      option :name, "mixcloud"

      option :client_options, {
        :site => 'https://www.mixcloud.com',
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/access_token'
      }

      option :access_token_options, {
        :header_format => 'OAuth %s',
        :param_name => 'access_token'
      }

      uid { raw_info['id'] }

      info do
        prune!({
          'nickname' => raw_info['username'],
          'name' => raw_info['name'],
          'image' => raw_info['pictures']['medium'],
          'urls' => {
            'Website' => raw_info['url']
          },
          'location' => raw_info['city']
        })
      end

      credentials do
        prune!({
          'expires' => access_token.expires?,
          'expires_at' => access_token.expires_at
        })
      end

      extra do
        prune!({
          'raw_info' => raw_info
        })
      end

      def raw_info
        @raw_info ||= access_token.get("https://api.mixcloud.com/me/?access_token=#{access_token.token}").parsed
      end

      def build_access_token
        super.tap do |token|
          token.options.merge!(access_token_options)
        end
      end

      def callback_url
        options[:callback_url] || (full_host + callback_path + query_string)
      end


      def access_token_options
        options.access_token_options.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }
      end

      def authorize_params
        super.tap do |params|
          %w[display state scope].each { |v| params[v.to_sym] = request.params[v] if request.params[v] }
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'mixcloud', 'MixCloud'
