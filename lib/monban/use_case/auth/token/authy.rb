require "monban/use_case/base"
require "monban/use_case/auth/token"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Token
        class Authy < Base
          include Token::Helper

          initialize_with(
            error:  [:invalid_params!, :server_error!],
            logger: [:log],
            time:   [:now],
            token:  [:create],
            auth:   [:authy],

            expire: Integer,

            repository: [
              :transaction,
              :public_id_exists?,
              :insert_public_id,
              :authy_id,
              :login_id,
            ],
          )

          def create(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer{|val| param_error!(account_id: val) },
              )
            end or param_error!(params: params)

            repository.transaction do
              auth.authy(
                public_id:  generate_public_id!(account_id: params[:account_id]),
                authy_id:   repository.authy_id(account_id: params[:account_id]),
                expired_at: time.now + expire,
              )
            end
          end

        end
      end
    end
  end
end
