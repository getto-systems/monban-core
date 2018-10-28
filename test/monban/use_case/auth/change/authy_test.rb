require "test_helper"

require "monban/use_case/auth/change/authy"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::Change::AuthyTest
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

  class Authy
    def initialize(params)
      @params = params
    end

    def register_user(country_code:, phone_number:)
      @params[:register_user]
    end
  end

  class Repository
    attr_reader :result

    def transaction
      yield
    end

    def update_authy_id(params)
      @result = params
    end
  end

  describe Monban::UseCase::Auth::Change::Authy do
    describe "register" do
      it "update account's authy_id" do
        now = ::Time.now

        authy = Authy.new(
          register_user: 10,
        )

        repository = Repository.new

        Monban::UseCase::Auth::Change::Authy.new(
          error: AppError,
          time: Time.new(now),
          authy: authy,
          repository: repository,
        )
          .change(
            account_id: 1,
            country_code: "81",
            phone_number: "080-xxxx-xxxx",
          )

        assert_equal(
          repository.result,
          {
            account_id: 1,
            authy_id: 10,
            now: now,
          }
        )
      end

      it "failed if account_id not well-formed" do
        now = ::Time.now

        authy = Authy.new(
          register_user: 10,
        )

        repository = Repository.new

        assert_raises AppError do
          Monban::UseCase::Auth::Change::Authy.new(
            error: AppError,
            time: Time.new(now),
            authy: authy,
            repository: repository,
          )
            .change(
              account_id: nil,
              country_code: "81",
              phone_number: "080-xxxx-xxxx",
            )
        end
      end

      it "failed if empty country_code" do
        now = ::Time.now

        authy = Authy.new(
          register_user: 10,
        )

        repository = Repository.new

        assert_raises AppError do
          Monban::UseCase::Auth::Change::Authy.new(
            error: AppError,
            time: Time.new(now),
            authy: authy,
            repository: repository,
          )
            .change(
              account_id: 1,
              country_code: "",
              phone_number: "080-xxxx-xxxx",
            )
        end
      end

      it "failed if empty phone_number" do
        now = ::Time.now

        authy = Authy.new(
          register_user: 10,
        )

        repository = Repository.new

        assert_raises AppError do
          Monban::UseCase::Auth::Change::Authy.new(
            error: AppError,
            time: Time.new(now),
            authy: authy,
            repository: repository,
          )
            .change(
              account_id: 1,
              country_code: "81",
              phone_number: "",
            )
        end
      end

      it "failed with invalid authy account" do
        now = ::Time.now

        authy = Authy.new(
          authy_id: nil,
        )

        repository = Repository.new

        assert_raises AppError do
          Monban::UseCase::Auth::Change::Authy.new(
            error: AppError,
            time: Time.new(now),
            authy: authy,
            repository: repository,
          )
            .change(
              account_id: 1,
              country_code: "81",
              phone_number: "080-xxxx-xxxx",
            )
        end
      end
    end
  end
end
