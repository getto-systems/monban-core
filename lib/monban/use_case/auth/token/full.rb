require "monban/core"
require "monban/use_case/base"
require "monban/use_case/auth/token"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Token
        class Full < Base
          include Token::Helper

          initialize_with(
            error:  Monban::Core::ERRORS,
            logger: [:log],
            time:   [:now],
            token:  [:create],
            auth:   [:full],

            expire: Integer,

            repository: [
              :transaction,
              :public_id_exists?,
              :insert_public_id,
              :roles,
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
              auth.full(
                public_id:  generate_public_id!(account_id: params[:account_id]),
                roles:      repository.roles(account_id: params[:account_id]),
                expired_at: time.now + expire,
              )
            end
          end

        end
      end
    end
  end
end
