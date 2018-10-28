require "test_helper"

require "monban/use_case/auth/token/reset"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::Token::ResetTest
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

    def public_id_exists?(params)
      @params[:public_id_exists]
    end

    def insert_public_id(params)
    end

    def login_id(account_id:)
    end

    def account_id_by_email(params)
      @params[:account_id]
    end

    def reset_password_token_exists?(params)
      @params[:reset_password_token_exists]
    end

    def insert_reset_password_token(params)
    end

    def wipe_old_reset_password_token(params)
    end
  end

  class Token
    def initialize(token)
      @token = token
    end

    def create
      @token
    end
  end

  class Auth
    def reset(params)
      params
    end
  end

  class Mailer
    attr_reader :params

    def send_mail(params)
      @params = params
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

  describe Monban::UseCase::Auth::Token::Reset do
    describe "send" do
      it "send reset token with account data" do
        repository = Repository.new(
          public_id_exists: false,
          account_id: 1,
        )

        now = ::Time.now

        mailer = Mailer.new

        Monban::UseCase::Auth::Token::Reset.new(
          error: AppError,
          time: Time.new(now),
          logger: Logger.new,
          token: Token.new("TOKEN"),
          reset_token: Token.new("RESET"),
          auth: Auth.new,
          mailer: mailer,

          expire: 10,

          repository: repository,
        )
          .send_mail(
            email: "email@example.com",
          )

        assert_equal(
          mailer.params,
          {email: "email@example.com", token: {public_id: "TOKEN", reset_token: "RESET", expired_at: now + 10}}
        )
      end

      it "raise AppError when email not include '@'" do
        repository = Repository.new(
          public_id_exists: true,
          account_id: 1,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Reset.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new("TOKEN"),
            reset_token: Token.new("RESET"),
            auth: Auth.new,
            mailer: Mailer.new,

            expire: 10,

            repository: repository,
          )
            .send_mail(
              email: "email",
            )
        end
      end

      it "raise AppError when account_id not found" do
        repository = Repository.new(
          public_id_exists: true,
          account_id: nil,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Reset.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new("TOKEN"),
            reset_token: Token.new("RESET"),
            auth: Auth.new,
            mailer: Mailer.new,

            expire: 10,

            repository: repository,
          )
            .send_mail(
              email: "email",
            )
        end
      end

      it "raise AppError when unused public_id not found" do
        repository = Repository.new(
          public_id_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Reset.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new("TOKEN"),
            reset_token: Token.new("RESET"),
            auth: Auth.new,
            mailer: Mailer.new,

            expire: 10,

            repository: repository,
          )
            .send_mail(
              email: "email@example.com",
            )
        end
      end

      it "raise AppError when unused reset_token not found" do
        repository = Repository.new(
          account_id: 1,
          reset_password_token_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Token::Reset.new(
            error: AppError,
            time: Time.new(now),
            logger: Logger.new,
            token: Token.new("TOKEN"),
            reset_token: Token.new("RESET"),
            auth: Auth.new,
            mailer: Mailer.new,

            expire: 10,

            repository: repository,
          )
            .send_mail(
              email: "email@example.com",
            )
        end
      end
    end
  end
end
