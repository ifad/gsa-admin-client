require 'hawk/http'

module GSA

  class Client < Hawk::HTTP
    def initialize(hostname:, username:, password:)
      super(hostname)

      @username = username
      @password = password

      authenticate!
    end

    def authenticate!
      body = request('POST', '/accounts/ClientLogin', auth: false, Email: @username, Passwd: @password)
      if body =~ /^Auth=(\w+)/
        @token = $1
      else
        raise Error, "Authentication failed: #{body}"
      end
    end

    def inspect
      super.sub(/>$/, ", auth: #@token>")
    end

    def logs
      get '/feeds/searchLog'
    end

    protected
      def parse(body)
        Nokogiri.parse(body)
      end

      def build_request_options_from(method, options)
        unless options.delete(:auth) === false
          options[:headers] ||= {}
          options[:headers]['Authorization'] = "GoogleLogin auth=#@token"
          options[:headers]['Content-Type']  = 'application/atom+xml'
        end

        super
      end
  end

end
