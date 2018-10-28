require "monban/core"
require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      module Change
        class Roles < Base

          initialize_with(
            error: Monban::Core::ERRORS,
            time:  [:now],
            repository: [
              :transaction,
              :account_exists?,
              :update_roles,
              :roles,
            ],

            accept_roles: Array,
          )

          def change(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer                                {|val| param_error!(account_id: val) },
                roles:      v.array_include(accept_roles.map(&:to_s)){|val| param_error!(roles: val) },
              )
            end or param_error!(params: params)

            repository.transaction do
              unless repository.account_exists?(account_id: params[:account_id])
                error.not_found! "account_id: #{params[:account_id]}"
              end

              repository.update_roles(
                account_id: params[:account_id],
                roles:      params[:roles],
                now:        time.now,
              )

              repository.roles(account_id: params[:account_id])
            end
          end

        end
      end
    end
  end
end
