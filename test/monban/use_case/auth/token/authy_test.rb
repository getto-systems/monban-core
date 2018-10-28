require "test_helper"

require "monban/use_case/auth/token/authy"

module Monban::UseCase::Auth::Token::AuthyTest
  class AppError < RuntimeError
    def self.invalid_params!(params)
      raise self, "invalid_params"
    end
    def self.server_error!(params)
      raise self, "server_error"
    end
  end

  class Logger
    def log(data)
    end
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def transaction
      yield
    end

    def public_id_exists?(params)
      @params[:public_id_exists]
    end

    def insert_public_id(params)
    end

    def authy_id(account_id:)
      @params[:authy_id]
    end

    def login_id(account_id:)
    end
  end

  class Token
    def create
      "TOKEN"
    end
  end

  class Auth
    def authy(params)
      params
    end
  end

  class Time
    def initialize(now)
      @now = now
    end

    def now
      @now
    end
  end

  describe Monban::UseCase::Auth::Token::Authy do
    describe "create" do
      it "create authy token with account data" do
        repository = Repository.new(
          public_id_exists: false,
          authy_id: 1,
        )

        now = ::Time.now

        assert_equal(
          Monban::UseCase::Auth::Token::Authy.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,

            repository: repository,
          )
            .create(
              account_id: 1,
            ),

            {public_id: "TOKEN", authy_id: 1, expired_at: now + 10}
        )
      end

      it "failed if account_id not well-formed" do
        repository = Repository.new(
          public_id_exists: false,
          authy_id: 1,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Authy.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,

            repository: repository,
          )
            .create(
              account_id: nil,
            )
        end
      end

      it "raise AppError when unused public_id not found" do
        repository = Repository.new(
          public_id_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Authy.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,

            repository: repository,
          )
            .create(
              account_id: 1,
            )
        end
      end
    end
  end
end
