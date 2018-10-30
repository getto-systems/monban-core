require "test_helper"

require "monban/use_case/auth/token/general"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::Token::GeneralTest
  class AppError < Monban::CoreTest::AppError
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def login_type(params)
      @params[:login_type]
    end
  end

  class FullToken < Monban::UseCase::Auth::Token::Full
    def initialize
    end

    def create(params)
      {type: :full, params: params}
    end
  end

  class AuthyToken < Monban::UseCase::Auth::Token::Authy
    def initialize
    end

    def create(params)
      {type: :authy, params: params}
    end
  end

  describe Monban::UseCase::Auth::Token::General do
    describe "create" do
      it "create full token with full login type" do
        repository = Repository.new(
          login_type: "full",
        )

        assert_equal(
          Monban::UseCase::Auth::Token::General.new(
            error: AppError,
            repository: repository,
            full:  FullToken.new,
            authy: AuthyToken.new,
          )
            .create(
              account_id: 1,
            ),

            {type: :full, params: {account_id: 1}}
        )
      end

      it "create authy token with authy login type" do
        repository = Repository.new(
          login_type: "authy",
        )

        assert_equal(
          Monban::UseCase::Auth::Token::General.new(
            error: AppError,
            repository: repository,
            full:  FullToken.new,
            authy: AuthyToken.new,
          )
            .create(
              account_id: 1,
            ),

            {type: :authy, params: {account_id: 1}}
        )
      end

      it "raise error with unknown login type" do
        repository = Repository.new(
          login_type: "unknown",
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Token::General.new(
            error: AppError,
            repository: repository,
            full:  FullToken.new,
            authy: AuthyToken.new,
          )
            .create(
              account_id: 1,
            )
        end
      end
    end
  end
end
