require "getto/initialize_with"

module Monban
  module Domain
    module Password
      module Helper
        private

          def digest(password:)
            password_digest.call(password + password_secret)
          end
      end

      class Creater
        include Getto::InitializeWith
        include Helper

        initialize_with(
          password_creater: [:create],
          password_digest:  [:call],
          password_secret:  String,
        )

        def create(password:)
          password_creater.create(
            password: digest(password: password),
          )
        end
      end

      class Checker
        include Getto::InitializeWith
        include Helper

        initialize_with(
          password_checker: [:hash_secret],
          password_digest:  [:call],
          password_secret:  String,
        )

        def hash_secret(password:, salt:)
          password_checker.hash_secret(
            password: digest(password: password),
            salt: salt,
          )
        end
      end

    end
  end
end
