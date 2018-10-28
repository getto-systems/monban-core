require "monban/core"
require "monban/use_case/base"

require "getto/params"

module Monban
  module UseCase
    module Auth
      class Account < Base

        initialize_with(
          error: Monban::Core::ERRORS,
          time:  [:now],

          account: ::Hash,

          repository: [
            :account_id_by_public_id,
          ],
        )

        def id
          @id ||= begin
            Getto::Params.new.validate(account) do |v|
              v.hash(
                public_id: v.combine([v.string, v.not_empty]){|val| param_error!(public_id: val) },
              )
            end or param_error!(account: account)

            repository.account_id_by_public_id(
              public_id: account[:public_id],
              now:       time.now,
            ) or error.invalid_account! "public_id: #{account[:public_id]}"
          end
        end

        def [](key)
          account[key]
        end

      end
    end
  end
end
