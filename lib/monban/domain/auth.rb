require "getto/initialize_with"

require "getto/params"
require "jwt"

module Monban
  module Domain
    module Auth
      class DecodeError < RuntimeError; end
      class SettingError < RuntimeError; end

      module Claim
        def iss(type)
          "#{type}@#{jwt_service}"
        end

        def authy_roles
          ["registered","unregistered"]
        end
      end

      class Encoder
        include Getto::InitializeWith
        include Claim

        initialize_with :jwt_service, :jwt_secret, :jwt_algorithm, :time

        def full(public_id:, roles:, expired_at:)
          to_jwt full_payload(
            public_id:  public_id,
            roles:      roles,
            expired_at: expired_at,
          )
        end

        def authy(public_id:, authy_id:, expired_at:)
          to_jwt authy_payload(
            public_id:  public_id,
            authy_id:   authy_id,
            expired_at: expired_at,
          )
        end

        def reset(public_id:, reset_token:, expired_at:)
          to_jwt reset_payload(
            public_id:   public_id,
            reset_token: reset_token,
            expired_at:  expired_at,
          )
        end

        private

          def to_jwt(payload)
            ::JWT.encode(payload, jwt_secret, jwt_algorithm)
          end

          def full_payload(public_id:, roles:, expired_at:)
            {
              iss: iss(:full),
              iat: time.now.to_i,
              exp: expired_at.to_i,

              sub: public_id,
              aud: roles,
            }
          end

          def authy_payload(public_id:, authy_id:, expired_at:)
            {
              iss: iss(:authy),
              iat: time.now.to_i,
              exp: expired_at.to_i,

              sub: public_id,
              aud: authy_id ? authy_roles.first : authy_roles.last,
            }
          end

          def reset_payload(public_id:, reset_token:, expired_at:)
            {
              iss: iss(:reset),
              iat: time.now.to_i,
              exp: expired_at.to_i,

              sub: public_id,
              aud: reset_token,
            }
          end
      end

      class Decoder
        include Getto::InitializeWith
        include Claim

        initialize_with :jwt_service, :jwt_secret, :jwt_algorithm,
          :public_id_length, :reset_token_length,
          :all_roles, :allow_full_access

        def decode(token, type:, roles:)
          case type
          when :full
            full_format ::JWT.decode(
              token,
              jwt_secret,
              true,

              algorithm: jwt_algorithm,

              verify_iss: true, iss: iss(type),
              verify_iat: true,
              verify_sub: true,

              verify_aud: !!roles, aud: ([*roles] + allow_full_access).map(&:to_s),
            )
          when :authy
            authy_format ::JWT.decode(
              token,
              jwt_secret,
              true,

              algorithm: jwt_algorithm,

              verify_iss: true, iss: iss(type),
              verify_iat: true,
              verify_sub: true,

              verify_aud: roles[:only_registered], aud: authy_roles.first,
            )
          when :reset
            reset_format ::JWT.decode(
              token,
              jwt_secret,
              true,

              algorithm: jwt_algorithm,

              verify_iss: true, iss: iss(type),
              verify_sub: true,
              verify_iat: true,
            )
          else
            raise SettingError, "decode: invalid type: #{type}"
          end
        rescue ::JWT::DecodeError => e
          error! e.message
        end

        private

          def full_format(result)
            payload, header = result

            validate_header! header
            validate_full!   payload

            {
              public_id: payload["sub"],
              roles:     payload["aud"],
            }
          end

          def authy_format(result)
            payload, header = result

            validate_header! header
            validate_authy!  payload

            {
              public_id: payload["sub"],
            }
          end

          def reset_format(result)
            payload, header = result

            validate_header! header
            validate_reset!  payload

            {
              public_id:   payload["sub"],
              reset_token: payload["aud"],
            }
          end


          def validate_header!(header)
            Getto::Params.new.validate(header) do |v|
              v.hash_strict(
                "alg" => v.string, # verified by jwt
              )
            end or error! "header: #{header}"
          end

          def validate_full!(payload)
            aud = (all_roles + allow_full_access).map(&:to_s)

            Getto::Params.new.validate(payload) do |v|
              v.hash_strict(
                "iss" => v.string,  # verified by jwt
                "iat" => v.integer, # verified by jwt
                "exp" => v.integer, # verified by jwt

                "sub" => v.combine([v.string, v.length(public_id_length)]){|val| error! "sub: #{val}" },
                "aud" => v.array_include(aud)                             {|val| error! "aud: #{val}" },
              )
            end or error! "full: #{payload}"
          end

          def validate_authy!(payload)
            Getto::Params.new.validate(payload) do |v|
              v.hash_strict(
                "iss" => v.string,  # verified by jwt
                "iat" => v.integer, # verified by jwt
                "exp" => v.integer, # verified by jwt

                "sub" => v.combine([v.string, v.length(public_id_length)]){|val| error! "sub: #{val}" },
                "aud" => v.combine([v.string, v.in(authy_roles)])         {|val| error! "aud: #{val}" },
              )
            end or error! "authy: #{payload}"
          end

          def validate_reset!(payload)
            Getto::Params.new.validate(payload) do |v|
              v.hash_strict(
                "iss" => v.string,  # verified by jwt
                "iat" => v.integer, # verified by jwt
                "exp" => v.integer, # verified by jwt

                "sub" => v.combine([v.string, v.length(public_id_length)])  {|val| error! "sub: #{val}" },
                "aud" => v.combine([v.string, v.length(reset_token_length)]){|val| error! "aud: #{val}" },
              )
            end or error! "reset: #{payload}"
          end

          def error!(message)
            raise DecodeError, message
          end
      end

      class Authorized
        include Getto::InitializeWith

        initialize_with :authorized_secret, :authorized_algorithm

        def decode(token)
          ::JWT.decode(
            token,
            authorized_secret,
            true,
            {
              algorithm: authorized_algorithm,
            }
          ).first
        rescue ::JWT::DecodeError => e
          error! e.message
        end

        def encode(account)
          ::JWT.encode(
            account,
            authorized_secret,
            authorized_algorithm
          )
        end

        def error!(message)
          raise DecodeError, message
        end
      end
    end
  end
end
