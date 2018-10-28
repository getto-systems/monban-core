require "monban/core"
require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      module Change
        class Email < Base

          initialize_with(
            error: Monban::Core::ERRORS,
            time:  [:now],
            repository: [
              :transaction,
              :account_exists?,
              :reset_password_email_account,
              :update_reset_password_email,
              :reset_password_email,
            ],
          )

          def change(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer            {|val| param_error!(account_id: val) },
                email:      v.combine([v.string]){|val| param_error!(email: val) },
              )
            end or param_error!(params: params)

            repository.transaction do
              unless repository.account_exists?(account_id: params[:account_id])
                error.not_found! "account_id: #{params[:account_id]}"
              end

              email_account = repository.reset_password_email_account(email: params[:email])

              if email_account && email_account != params[:account_id]
                error.conflict! "email: #{params[:email]}"
              end

              unless email_account
                repository.update_reset_password_email(
                  account_id: params[:account_id],
                  email:      params[:email],
                  now:        time.now,
                )
              end

              {
                email: repository.reset_password_email(account_id: params[:account_id]),
              }
            end
          end

        end
      end
    end
  end
end
