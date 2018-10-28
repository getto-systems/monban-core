module Monban
  module UseCase
    module Auth
      module Token
        module Helper
          private

            def generate_public_id!(account_id:)
              i = 0
              while i < 100 do
                i += 1

                public_id = token.create
                unless repository.public_id_exists?(public_id: public_id)
                  repository.insert_public_id(
                    account_id: account_id,
                    public_id:  public_id,
                    created_at: time.now,
                    expired_at: time.now + expire,
                  )

                  logger.log(generate_public_id: {
                    account_id: account_id,
                    public_id:  public_id,
                    login_id:   repository.login_id(account_id: account_id),
                  })

                  return public_id
                end
              end

              error.server_error! "failed generate public_id"
            end

        end
      end
    end
  end
end
