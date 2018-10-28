require "test_helper"

require "monban/use_case/account/change/email"

module Monban::UseCase::Account::Change::EmailTest
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

    def reset_password_email_account(params)
      @params[:reset_password_email_account]
    end

    def update_reset_password_email(params)
      @result = params
    end

    def reset_password_email(params)
      @params[:reset_password_email]
    end
  end

  describe Monban::UseCase::Account::Change::Email do
    describe "update account data with valid account_id" do
      it "update email" do
        repository = Repository.new(
          account_exists: true,
          reset_password_email_account: nil,
          reset_password_email: "user@example.com",
        )

        now = ::Time.now

        assert_equal(
          Monban::UseCase::Account::Change::Email.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              email: "user@example.com",
            ),

          {
            email: "user@example.com",
          }
        )

        assert_equal(
          repository.result,
          {
            account_id: 1,
            email: "user@example.com",
            now: now,
          }
        )
      end

      it "error if account_id not well-formed" do
        repository = Repository.new(
          account_exists: true,
          reset_password_email_account: 1,
          reset_password_email: "user@example.com",
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Email.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: nil,
              email: "user@example.com",
            )
        end
      end

      it "error if email not well-formed" do
        repository = Repository.new(
          account_exists: false,
          reset_password_email_account: 1,
          reset_password_email: "user@example.com",
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Email.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              email: nil,
            )
        end
      end

      it "not_found error if account_id not found" do
        repository = Repository.new(
          account_exists: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Email.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              email: "user@example.com",
            )
        end
      end

      it "conflict error if email exists" do
        repository = Repository.new(
          account_exists: true,
          reset_password_email_account: 2,
          reset_password_email: "user@example.com",
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Change::Email.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
          )
            .change(
              account_id: 1,
              email: "user@example.com",
            )
        end
      end
    end
  end
end
