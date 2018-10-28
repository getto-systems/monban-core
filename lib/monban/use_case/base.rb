require "getto/initialize_with"

module Monban
  module UseCase
    class Base
      include Getto::InitializeWith

      private

        def param_error!(params)
          error.invalid_params! params.map{|k,v| "#{k}: #{v}"}
        end
    end
  end
end
