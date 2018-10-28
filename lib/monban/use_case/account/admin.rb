require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Account
      class Admin < Base

        initialize_with(
          time: [:now],
          repository: [
            :transaction,
            :reset_password_email_account,
            :insert_account,
            :update_roles,
            :update_reset_password_email,
          ],

          admin_email: String,
          admin_roles: Array,
        )

        def register
          repository.transaction do
            unless account_id = repository.reset_password_email_account(email: admin_email)
              account_id = repository.insert_account(now: time.now)
            end

            repository.update_roles(
              account_id: account_id,
              roles: admin_roles,
              now: time.now,
            )

            repository.update_reset_password_email(
              account_id: account_id,
              email: admin_email,
              now: time.now,
            )

            nil
          end
        end

      end
    end
  end
end
