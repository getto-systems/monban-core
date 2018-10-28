require "test_helper"

require "monban/use_case/auth/verify/authy"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::Verify::AuthyTest
  class AppError < Monban::CoreTest::AppError
  end

  class Authy
    def initialize(params)
      @params = params
    end

    attr_reader :result

    def verify(params)
      @result = params if @params[:verify]
    end
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def authy_id(params)
      @params[:authy_id]
    end
  end

  describe Monban::UseCase::Auth::Verify::Authy do
    describe "verify" do
      it "verify token of authy_id" do
        repository = Repository.new(
          authy_id: 10,
        )

        authy = Authy.new(
          verify: true,
        )

        Monban::UseCase::Auth::Verify::Authy.new(
          error: AppError,
          authy: authy,
          repository: repository,
        )
          .verify(
            account_id: 1,
            authy_token: "xxxx",
          )

        assert_equal(
          authy.result,
          {authy_id: 10, authy_token: "xxxx"}
        )
      end

      it "failed if account_id not well-formed" do
        repository = Repository.new(
          authy_id: 10,
        )

        authy = Authy.new(
          verify: true,
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Authy.new(
            error: AppError,
            authy: authy,
            repository: repository,
          )
            .verify(
              account_id: nil,
              authy_token: "xxxx",
            )
        end
      end

      it "failed if empty authy_token" do
        repository = Repository.new(
          authy_id: 10,
        )

        authy = Authy.new(
          verify: true,
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Authy.new(
            error: AppError,
            authy: authy,
            repository: repository,
          )
            .verify(
              account_id: 1,
              authy_token: "",
            )
        end
      end

      it "failed if authy_id not found" do
        repository = Repository.new(
          authy_id: nil,
        )

        authy = Authy.new(
          verify: true,
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Authy.new(
            error: AppError,
            authy: authy,
            repository: repository,
          )
            .verify(
              account_id: 1,
              authy_token: "xxxx",
            )
        end
      end

      it "failed with invalid authy account" do
        repository = Repository.new(
          authy_id: 10,
        )

        authy = Authy.new(
          verify: false,
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Authy.new(
            error: AppError,
            authy: authy,
            repository: repository,
          )
            .verify(
              account_id: 1,
              authy_token: "xxxx",
            )
        end
      end
    end
  end
end
