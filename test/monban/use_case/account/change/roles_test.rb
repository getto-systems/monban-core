require "test_helper"

require "monban/use_case/account/change/roles"

require "monban/core_test/app_error"

module Monban::UseCase::Account::Change::RolesTest
  class AppError < Monban::CoreTest::AppError
  end

  class Time
    def initialize(now)
      @now = now
    end

    def now
      @now
    end
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

    def update_roles(params)
    end

    def roles(params)
      @params[:roles]
    end
  end

  describe Monban::UseCase::Account::Change::Roles do
    describe "update account data with valid account_id" do
      it "update roles" do
        repository = Repository.new(
          account_exists: true,
          roles: ["user","system"],
        )

        now = ::Time.now

        assert_equal(
          Monban::UseCase::Account::Change::Roles.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            accept_roles: [:user,:system,:admin],
          )
            .change(
              account_id: 1,
              roles: ["user","system"],
            ),

          ["user","system"]
        )
      end

      it "error if account_id not well-formed" do
        repository = Repository.new(
          account_exists: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Roles.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            accept_roles: [:user,:system,:admin],
          )
            .change(
              account_id: nil,
              roles: ["user"],
            )
        end
      end

      it "error if unknown role" do
        repository = Repository.new(
          account_exists: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Roles.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            accept_roles: [:user,:system,:admin],
          )
            .change(
              account_id: 1,
              roles: ["super"],
            )
        end
      end

      it "not_found error if account_id not found" do
        repository = Repository.new(
          account_exists: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Roles.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            accept_roles: [:user,:system,:admin],
          )
            .change(
              account_id: 1,
              roles: ["user","system"],
            )
        end
      end
    end
  end
end
