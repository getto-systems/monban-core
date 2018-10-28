require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      class Register < Base

        initialize_with(
          error: [:invalid_params!, :conflict!],
          time:  [:now],
          repository: [
            :transaction,
            :login_id_exists?,
            :insert_account,
            :update_login_id,
          ],
        )

        def create(params)
          Getto::Params.new.validate(params) do |v|
            v.hash(
              login_id: v.combine([v.string, v.not_empty]){|val| param_error!(login_id: val) },
            )
          end or param_error!(params: params)

          repository.transaction do
            if repository.login_id_exists?(login_id: params[:login_id])
              error.conflict! "login_id already exists"
            end

            account_id = repository.insert_account(
              now: time.now,
            )

            repository.update_login_id(
              account_id: account_id,
              login_id: params[:login_id],
              now:      time.now,
            )

            account_id
          end
        end

      end
    end
  end
end
