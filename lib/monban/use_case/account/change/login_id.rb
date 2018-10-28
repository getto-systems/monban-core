require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      module Change
        class LoginId < Base

          initialize_with(
            error: [:invalid_params!, :not_found!, :conflict!],
            time:  [:now],
            repository: [
              :transaction,
              :account_exists?,
              :login_id_account,
              :update_login_id,
              :login_id,
            ],
          )

          def change(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer{|val| param_error!(account_id: val) },
                login_id:   v.string {|val| param_error!(login_id: val) },
              )
            end or param_error!(params: params)

            repository.transaction do
              unless repository.account_exists?(account_id: params[:account_id])
                error.not_found! "account_id: #{params[:account_id]}"
              end

              login_id_account = repository.login_id_account(login_id: params[:login_id])
              if login_id_account && login_id_account != params[:account_id]
                error.conflict! "login_id: #{params[:login_id]}"
              end

              unless login_id_account
                repository.update_login_id(
                  account_id: params[:account_id],
                  login_id:   params[:login_id],
                  now:        time.now,
                )
              end

              repository.login_id(account_id: params[:account_id])
            end
          end

        end
      end
    end
  end
end
