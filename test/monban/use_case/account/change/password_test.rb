require "test_helper"

require "monban/use_case/account/change/password"

require "monban/core_test/app_error"

module Monban::UseCase::Account::Change::PasswordTest
  class AppError < Monban::CoreTest::AppError
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def transaction
      yield
    end

    def account_exists?(params)
      @params[:account_exists]
    end
  end

  class Password
    attr_reader :params

    def change(params)
      @params = params
    end
  end

  describe Monban::UseCase::Account::Change::Password do
    describe "change account's password" do
      it "change password of account_id" do
        repository = Repository.new(
          account_exists: true,
        )

        password = Password.new

        Monban::UseCase::Account::Change::Password.new(
          error: AppError,
          repository: repository,
          password:   password,
        )
          .change(
            account_id: 1,
            password: "PASSWORD",
          )

        assert_equal(
          password.params,
          { account_id: 1, password: "PASSWORD" }
        )
      end

      it "error if account_id not well-formed" do
        repository = Repository.new(
          account_exists: true,
        )

        assert_raises AppError do
          Monban::UseCase::Account::Change::Password.new(
            error: AppError,
            repository: repository,
            password:   Password.new,
          )
            .change(
              account_id: nil,
              password: "PASSWORD",
            )
        end
      end

      it "error if empty password" do
        repository = Repository.new(
          account_exists: true,
        )

        assert_raises AppError do
          Monban::UseCase::Account::Change::Password.new(
            error: AppError,
            repository: repository,
            password:   Password.new,
          )
            .change(
              account_id: 1,
              password: "",
            )
        end
      end

      it "not_found error if account not found" do
        repository = Repository.new(
          account_exists: false,
        )

        assert_raises AppError do
          Monban::UseCase::Account::Change::Password.new(
            error: AppError,
            repository: repository,
            password:   Password.new,
          )
            .change(
              account_id: 1,
              password: "PASSWORD",
            )
        end
      end
    end
  end
end
