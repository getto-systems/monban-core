require "test_helper"

require "monban/use_case/account/unregister"

require "monban/core_test/app_error"

module Monban::UseCase::Account::UnregisterTest
  class AppError < Monban::CoreTest::AppError
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

    def delete_account(params)
      @result = params
    end
  end

  describe Monban::UseCase::Account::Unregister do
    describe "unregister account" do
      it "unregister account data" do
        repository = Repository.new(
          account_exists: true,
        )

        Monban::UseCase::Account::Unregister.new(
          error: AppError,
          repository: repository,
        )
          .unregister(account_id: 1)

        assert_equal(
          repository.result,
          {
            account_id: 1,
          }
        )
      end

      it "failed if account_id not well-formed" do
        repository = Repository.new(
          account_exists: true,
        )

        assert_raises AppError do
          Monban::UseCase::Account::Unregister.new(
            error: AppError,
            repository: repository,
          )
            .unregister(account_id: nil)
        end
      end

      it "not_found error if login_id not found" do
        repository = Repository.new(
          account_exists: false,
        )

        assert_raises AppError do
          Monban::UseCase::Account::Unregister.new(
            error: AppError,
            repository: repository,
          )
            .unregister(account_id: 1)
        end
      end
    end
  end
end
