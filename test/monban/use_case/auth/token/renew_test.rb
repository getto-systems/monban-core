require "test_helper"

require "monban/use_case/auth/token/renew"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::Token::RenewTest
  class AppError < Monban::CoreTest::AppError
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

    def public_id_renew_enabled?(params)
      @params[:public_id_renew_enabled]
    end

    def public_id_original_created_at(params)
      @params[:public_id_original_created_at]
    end

    def public_id_exists?(params)
      @params[:public_id_exists]
    end

    def insert_public_id(params)
    end

    def preserve_public_id_original_created_at(params)
    end

    def roles(account_id:)
      @params[:roles]
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
    def full(params)
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

  describe Monban::UseCase::Auth::Token::Renew do
    describe "create" do
      it "create full auth_token with account data before original token not expired" do
        now = ::Time.now

        repository = Repository.new(
          public_id_renew_enabled: true,
          public_id_exists: false,
          public_id_original_created_at: now,
          roles: ["user","system"],
        )

        assert_equal(
          Monban::UseCase::Auth::Token::Renew.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,
            renew_expire: 100,

            repository: repository,
          )
            .create(
              account_id: 1,
              public_id: "public_id",
            ),

            {public_id: "TOKEN", roles: ["user","system"], expired_at: now + 10}
        )
      end

      it "failed if account_id not well-formed" do
        now = ::Time.now

        repository = Repository.new(
          public_id_renew_enabled: true,
          public_id_exists: false,
          public_id_original_created_at: now,
          roles: ["user","system"],
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Renew.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,
            renew_expire: 100,

            repository: repository,
          )
            .create(
              account_id: nil,
              public_id: "public_id",
            )
        end
      end

      it "failed if empty public_id" do
        now = ::Time.now

        repository = Repository.new(
          public_id_renew_enabled: true,
          public_id_exists: false,
          public_id_original_created_at: now,
          roles: ["user","system"],
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Renew.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,
            renew_expire: 100,

            repository: repository,
          )
            .create(
              account_id: 1,
              public_id: "",
            )
        end
      end

      it "raise AppError when renew expired" do
        repository = Repository.new(
          public_id_renew_enabled: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Renew.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,
            renew_expire: 100,

            repository: repository,
          )
            .create(
              account_id: 1,
              public_id: "public_id",
            )
        end
      end

      it "raise AppError when unused public_id not found" do
        repository = Repository.new(
          public_id_renew_enabled: true,
          public_id_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Renew.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new,
            auth: Auth.new,

            expire: 10,
            renew_expire: 100,

            repository: repository,
          )
            .create(
              account_id: 1,
              public_id: "public_id",
            )
        end
      end
    end
  end
end
