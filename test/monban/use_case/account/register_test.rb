require "test_helper"

require "monban/use_case/account/register"

module Monban::UseCase::Account::RegisterTest
  class AppError < RuntimeError
    def self.invalid_params!(params)
      raise self, "invalid_params"
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

    def login_id_exists?(params)
      @params[:login_id_exists]
    end

    def insert_account(params)
      1
    end

    def update_login_id(params)
      @result = params
    end
  end

  describe Monban::UseCase::Account::Register do
    describe "register account" do
      it "register by login_id" do
        repository = Repository.new(
          login_id_exists: false,
        )

        now = ::Time.now

        Monban::UseCase::Account::Register.new(
          error: AppError,
          time:  Time.new(now),
          repository: repository,
        )
          .create(
            login_id: "LOGIN_ID",
          )

        assert_equal(
          repository.result,
          {
            account_id: 1,
            login_id: "LOGIN_ID",
            now: now,
          }
        )
      end

      it "error if login_id not well-formed" do
        repository = Repository.new(
          login_id_exists: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Register.new(
            error: AppError,
            time:  Time.new(now),
            repository: repository,
          )
            .create(
              login_id: nil,
            )
        end
      end

      it "conflict error if login_id exists" do
        repository = Repository.new(
          login_id_exists: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Account::Register.new(
            error: AppError,
            time:  Time.new(now),
            repository: repository,
          )
            .create(
              login_id: "LOGIN_ID",
            )
        end
      end
    end
  end
end
