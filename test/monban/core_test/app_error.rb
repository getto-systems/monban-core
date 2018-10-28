module Monban
  module CoreTest
    class AppError < RuntimeError
      def self.invalid_account!(*params)
        raise self, "invalid_account"
      end
      def self.invalid_login!(*params)
        raise self, "invalid_login"
      end
      def self.invalid_params!(*params)
        raise self, "invalid_params"
      end
      def self.not_found!(*params)
        raise self, "not_found"
      end
      def self.renew_token_expired!(*params)
        raise self, "renew_token_expired"
      end
      def self.conflict!(*params)
        raise self, "conflict"
      end
      def self.server_error!(*params)
        raise self, "server_error"
      end
    end
  end
end
