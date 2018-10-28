require "test_helper"

require "monban/use_case/account/fetch"

require "monban/core_test/app_error"

module Monban::UseCase::Account::FetchTest
  class AppError < Monban::CoreTest::AppError
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def login_id(params)
      @params[:login_id]
    end

    def reset_password_email(params)
      @params[:reset_password_email]
    end

    def roles(params)
      @params[:roles]
    end
  end

  describe Monban::UseCase::Account::Fetch do
    describe "fetch account data" do
      it "fetch login_id, email and roles" do
        repository = Repository.new(
          login_id: "user",
          reset_password_email: "email@example.com",
          roles: ["user","system"],
        )

        assert_equal(
          Monban::UseCase::Account::Fetch.new(
            error: AppError,
            repository: repository,
          )
            .fetch(account_id: 1),

          {
            login_id: "user",
            roles:   ["user","system"],
            email: "email@example.com",
          }
        )
      end

      it "error if account_id not well-formed" do
        repository = Repository.new(
          login_id: "user",
          reset_password_email: "email@example.com",
          roles: ["user","system"],
        )

        assert_raises AppError do
          Monban::UseCase::Account::Fetch.new(
            error: AppError,
            repository: repository,
          )
            .fetch(account_id: nil)
        end
      end
    end
  end
end
