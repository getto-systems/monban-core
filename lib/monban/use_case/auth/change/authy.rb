require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Change
        class Authy < Base

          initialize_with(
            error: [:invalid_params!, :invalid_account!],
            time: [:now],
            authy: [:register_user],
            repository: [
              :transaction,
              :update_authy_id,
            ],
          )

          def change(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id:   v.integer                         {|val| param_error!(account_id: val) },
                country_code: v.combine([v.string, v.not_empty]){|val| param_error!(country_code: val) },
                phone_number: v.combine([v.string, v.not_empty]){|val| param_error!(phone_number: val) },
              )
            end or param_error!(params: params)

            authy_id = authy.register_user(
              country_code: params[:country_code],
              phone_number: params[:phone_number],
            ) or error.invalid_account! "params: #{params}"

            repository.transaction do
              repository.update_authy_id(
                account_id: params[:account_id],
                authy_id:   authy_id,
                now:        time.now,
              )
            end

            nil
          end

        end
      end
    end
  end
end
