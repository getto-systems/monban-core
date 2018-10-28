require "monban/core"
require "monban/use_case/base"
require "monban/use_case/auth/token"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Token
        class Renew < Base
          include Token::Helper

          initialize_with(
            error:  Monban::Core::ERRORS,
            logger: [:log],
            time:   [:now],
            token:  [:create],
            auth:   [:full],

            expire:       Integer,
            renew_expire: Integer,

            repository: [
              :transaction,
              :public_id_renew_enabled?,
              :public_id_original_created_at,
              :public_id_exists?,
              :insert_public_id,
              :preserve_public_id_original_created_at,
              :roles,
              :login_id,
            ],
          )

          def create(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                account_id: v.integer                         {|val| param_error!(account_id: val) },
                public_id:  v.combine([v.string, v.not_empty]){|val| param_error!(public_id: val) },
              )
            end or param_error!(params: params)

            repository.transaction do
              repository.public_id_renew_enabled?(
                public_id: params[:public_id],
                original_created_at: time.now - renew_expire,
              ) or error.renew_token_expired!

              original_created_at = repository.public_id_original_created_at(public_id: params[:public_id])

              new_public_id = generate_public_id!(account_id: params[:account_id])

              repository.preserve_public_id_original_created_at(
                public_id: new_public_id,
                original_created_at: original_created_at,
              )

              auth.full(
                public_id:  new_public_id,
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
