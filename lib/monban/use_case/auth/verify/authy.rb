require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Verify
        class Authy < Base

          initialize_with(
            error: [:invalid_params!, :invalid_account!],
            authy: [:verify],
            repository: [
              :authy_id,
            ],
          )

          def verify(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id:  v.integer                         {|val| param_error!(account_id: val) },
                authy_token: v.combine([v.string, v.not_empty]){|val| param_error!(authy_token: val) },
              )
            end or param_error!(params: params)

            authy_id = repository.authy_id(
              account_id: params[:account_id],
            ) or error.invalid_account! "account_id: #{params[:account_id]}"

            authy.verify(
              authy_id:    authy_id,
              authy_token: params[:authy_token],
            ) or error.invalid_account! "authy_token unmatched"

            nil
          end

        end
      end
    end
  end
end
