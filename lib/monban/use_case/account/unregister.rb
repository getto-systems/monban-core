require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      class Unregister < Base

        initialize_with(
          error: [:invalid_params!, :not_found!],
          repository: [
            :transaction,
            :account_exists?,
            :delete_account,
          ],
        )

        def unregister(params)
          Getto::Params.new.validate(params) do |v|
            v.hash(
              account_id: v.integer{|val| param_error!(account_id: val) },
            )
          end or param_error!(params: params)

          repository.transaction do
            unless repository.account_exists?(account_id: params[:account_id])
              error.not_found! "account_id: #{params[:account_id]}"
            end
            repository.delete_account(account_id: params[:account_id])
          end

          nil
        end

      end
    end
  end
end
