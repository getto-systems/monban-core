require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      module Change
        class Password < Base

          initialize_with(
            :error,
            repository: [
              :account_exists?,
            ],
            password: [:change],
          )

          def change(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer{|val| param_error!(account_id: val) },
                password:   v.combine([v.string, v.not_empty]), # DO NOT LOGGING PASSWORD!!
              )
            end or param_error!(params: "FILTERED")

            repository.transaction do
              unless repository.account_exists?(account_id: params[:account_id])
                error.not_found! "account_id: #{params[:account_id]}"
              end

              self.password.change(
                account_id: params[:account_id],
                password:   params[:password],
              )
            end

            nil
          end

        end
      end
    end
  end
end
