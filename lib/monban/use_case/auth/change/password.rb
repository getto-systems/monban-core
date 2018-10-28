require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Change
        class Password < Base

          initialize_with(
            repository: [
              :transaction,
              :delete_reset_password_token,
              :update_password_hash,
            ],
            time: [:now],

            password: [:create]
          )

          def change(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer                         {|val| param_error!(account_id: val) },
                password:   v.combine([v.string, v.not_empty]){|val| param_error!(password: val) },
              )
            end or param_error!(params: params)

            repository.transaction do
              # disable current reset-password token
              #   when user change own password
              repository.delete_reset_password_token(account_id: params[:account_id])

              repository.update_password_hash(
                account_id:    params[:account_id],
                password_hash: password.create(password: params[:password]),
                now:           time.now,
              )
            end

            nil
          end

        end
      end
    end
  end
end
