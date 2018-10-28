require "monban/use_case/base"

require "getto/params"
require "getto/params/search"

module Monban
  module UseCase
    module Account
      class Search < Base

        initialize_with(
          error: [:invalid_params!],
          repository: [:search],

          limit: Integer,
        )

        # :nocov:
        def search(params)
          Getto::Params.new.validate(params) do |v|
            v.hash(
              page: v.string{|val| param_error!(page: val) },
              sort: v.in([
                "login_id.asc",
                "login_id.desc",
              ]){|val| param_error!(sort: val) },
              query: v.hash(
                "login_id.cont" => v.string{|val| param_error!("login_id.cont": val) },
              ),
            )
          end or param_error!(params: params)


          repository.search(**(Getto::Params::Search.new(**params, limit: limit).to_h do |search|
            search.sort do |s|
              s.straight :login_id
            end
            search.query do |q|
              q.search "login_id.cont", &q.not_empty
            end
          end.to_h))
        end
        # :nocov:

      end
    end
  end
end
