require "monban/core"
require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Verify
        class ResetToken < Base
          include Getto::InitializeWith

          initialize_with(
            error: Monban::Core::ERRORS,
            time:  [:now],
            repository: [
              :valid_reset_password_token?,
            ],
          )

          def verify(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id:  v.integer                         {|val| param_error!(account_id: val) },
                reset_token: v.combine([v.string, v.not_empty]){|val| param_error!(reset_token: val) },
              )
            end or param_error!(params: params)

            repository.valid_reset_password_token?(
              account_id:  params[:account_id],
              reset_token: params[:reset_token],
              now:         time.now
            ) or error.invalid_account! "reset_token failed: #{params}"

            nil
          end

        end
      end
    end
  end
end
