require "test_helper"

require "monban/use_case/auth/token/general"

module Monban::UseCase::Auth::Token::GeneralTest
  class AppError < RuntimeError
    def self.server_error!(*args)
      raise self, "server_error: #{args.join " "}"
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
        assert_equal(
          Monban::UseCase::Auth::Token::General.new(
            error: AppError,
            login: :full,
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
        assert_equal(
          Monban::UseCase::Auth::Token::General.new(
            error: AppError,
            login: :authy,
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
        assert_raises AppError do
          Monban::UseCase::Auth::Token::General.new(
            error: AppError,
            login: :unknown,
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
