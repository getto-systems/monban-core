require "monban/use_case/base"
require "monban/use_case/auth/token"

require "getto/params"

module Monban
  module UseCase
    module Auth
      module Token
        class Reset < Base
          include Token::Helper

          initialize_with(
            error:       [:server_error!, :invalid_account!],
            time:        [:now],
            logger:      [:log],
            token:       [:create],
            reset_token: [:create],
            auth:        [:reset],
            mailer:      [:send_mail],

            expire: Integer,

            repository: [
              :transaction,
              :account_id_by_email,
              :public_id_exists?,
              :insert_public_id,
              :login_id,
              :wipe_old_reset_password_token,
              :reset_password_token_exists?,
              :insert_reset_password_token,
            ],
          )

          def send_mail(params)
            Getto::Params.new.validate(params) do |v|
              v.hash(
                email: v.combine([v.string, v.match(%r{@})]){|val| param_error!(email: val) },
              )
            end or param_error!(params: params)

            account_id = repository.account_id_by_email(
              email: params[:email],
            ) or error.invalid_account!

            token = create(
              account_id: account_id,
            )

            mailer.send_mail(
              email: params[:email],
              token: token,
            )

            nil
          end

          private

            def create(account_id:)
              repository.transaction do
                repository.wipe_old_reset_password_token(now: time.now)

                reset_token = generate_reset_token!(account_id: account_id)

                auth.reset(
                  public_id:   generate_public_id!(account_id: account_id),
                  reset_token: reset_token,
                  expired_at:  time.now + expire,
                )
              end
            end

            def generate_reset_token!(account_id:)
              i = 0
              while i < 100 do
                i += 1

                token = reset_token.create
                unless repository.reset_password_token_exists?(reset_token: token)
                  repository.insert_reset_password_token(
                    account_id:  account_id,
                    reset_token: token,
                    created_at:  time.now,
                    expired_at:  time.now + expire,
                  )
                  return token
                end
              end

              error.server_error! "failed generate reset_token"
            end

        end
      end
    end
  end
end
