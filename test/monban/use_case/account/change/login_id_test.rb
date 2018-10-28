require "test_helper"

require "monban/use_case/account/change/login_id"

module Monban::UseCase::Account::Change::LoginIdTest
  class AppError < RuntimeError
    def self.invalid_params!(params)
      raise self, "invalid_params"
    end
    def self.not_found!(params)
      raise self, "not_found"
    end
    def self.conflict!(params)
      raise self, "conflict"
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

  class Repository
    def initialize(params)
      @params = params
    end

    attr_reader :result

    def transaction
      yield
    end

    def account_exists?(params)
      @params[:account_exists]
    end

    def login_id_account(params)
      @params[:login_id_account]
    end

    def update_login_id(params)
      @result = params
    end

    def login_id(params)
      @params[:login_id]
    end
  end

  describe Monban::UseCase::Account::Change::LoginId do
    describe "update account data with valid account_id" do
      it "update login_id" do
        repository = Repository.new(
          account_exists: true,
          login_id_account: nil,
          login_id: "user",
        )

        now = ::Time.now

        assert_equal(
          Monban::UseCase::Account::Change::LoginId.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              login_id: "user",
            ),

          "user"
        )

        assert_equal(
          repository.result,
          {
            account_id: 1,
            login_id: "user",
            now: now,
          }
        )
      end

      it "error if account_id not well-formed" do
        repository = Repository.new(
          account_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::LoginId.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: nil,
              login_id: "user",
            )
        end
      end

      it "error if login_id not well-formed" do
        repository = Repository.new(
          account_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::LoginId.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              login_id: nil,
            )
        end
      end

      it "not_found error if account_id not found" do
        repository = Repository.new(
          account_exists: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::LoginId.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              login_id: "user",
            )
        end
      end

      it "conflict error if login_id exists" do
        repository = Repository.new(
          account_exists: true,
          login_id_account: 2,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::LoginId.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              login_id: "user",
            )
        end
      end
    end
  end
end
