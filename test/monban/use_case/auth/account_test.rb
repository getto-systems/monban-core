require "test_helper"

require "monban/use_case/auth/account"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::AccountTest
  class AppError < Monban::CoreTest::AppError
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def account_id_by_public_id(params)
      @params[:account_id]
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

  describe Monban::UseCase::Auth::Account do
    describe "id" do
      it "returns account id" do
        repository = Repository.new(
          account_id: 1,
        )

        now = ::Time.now

        account = {
          public_id: "public_id",
        }

        assert_equal(
          Monban::UseCase::Auth::Account.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            account: account,
          )
            .id,
          1
        )
      end

      it "failed if empty public_id" do
        repository = Repository.new(
          account_id: 1,
        )

        now = ::Time.now

        account = {
          public_id: "",
        }

        assert_raises AppError do
          Monban::UseCase::Auth::Account.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            account: account,
          )
            .id
        end
      end

      it "failed public_id missing" do
        repository = Repository.new(
          account_id: 1,
        )

        now = ::Time.now

        account = {
        }

        assert_raises AppError do
          Monban::UseCase::Auth::Account.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            account: account,
          )
            .id
        end
      end

      it "failed if account not found" do
        repository = Repository.new(
          account_id: nil,
        )

        now = ::Time.now

        account = {
          public_id: "public_id",
        }

        assert_raises AppError do
          Monban::UseCase::Auth::Account.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            account: account,
          )
            .id
        end
      end
    end

    describe "[]" do
      it "returns account data" do
        repository = Repository.new(
          account_id: 1,
        )

        now = ::Time.now

        account = {
          public_id: "public_id",
          key: "value",
        }

        assert_equal(
          Monban::UseCase::Auth::Account.new(
            error: AppError,
            repository: repository,
            time: Time.new(now),
            account: account,
          )[:key],
          "value"
        )
      end
    end
  end
end
