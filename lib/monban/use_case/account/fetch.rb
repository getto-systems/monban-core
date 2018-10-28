require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      class Fetch < Base

        initialize_with(
          error: [:invalid_params!],
          repository: [
            :login_id,
            :reset_password_email,
            :roles,
          ],
        )

        def fetch(params)
          Getto::Params.new.validate(params) do |v|
            v.hash(
              account_id: v.integer{|val| param_error!(account_id: val) },
            )
          end or param_error!(params: params)

          {
            login_id: repository.login_id(account_id: params[:account_id]),
            email:    repository.reset_password_email(account_id: params[:account_id]),
            roles:    repository.roles(account_id: params[:account_id]),
          }
        end

      end
    end
  end
end
