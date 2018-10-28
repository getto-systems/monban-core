require "monban/core"
require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Verify
        class Password < Base
          include Getto::InitializeWith

          initialize_with(
            error: Monban::Core::ERRORS,
            repository: [
              :account_id_by_login_id,
              :password_salt,
              :password_hash_match?,
            ],

            password: [:hash_secret],
          )

          def verify(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                login_id: v.combine([v.string, v.not_empty]){|val| param_error!(login_id: val) },
                password: v.combine([v.string, v.not_empty]){|val| param_error!(password: val) },
              )
            end or param_error!(params: params)

            account_id = repository.account_id_by_login_id(
              login_id: params[:login_id],
            ) or error.invalid_account! "login_id: #{params[:login_id]}"

            password_match?(
              account_id: account_id,
              password:   params[:password],
            ) or error.invalid_login! "password not matched"

            account_id
          end

          private

            def password_match?(account_id:, password:)
              unless salt = repository.password_salt(account_id: account_id)
                error.invalid_login! "password not registered"
              end

              password_hash = self.password.hash_secret(
                password: password,
                salt: salt,
              )

              repository.password_hash_match?(
                account_id:    account_id,
                password_hash: password_hash,
              )
            end

        end
      end
    end
  end
end
