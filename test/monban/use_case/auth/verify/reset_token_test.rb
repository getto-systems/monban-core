require "test_helper"

require "monban/use_case/auth/verify/reset_token"

module Monban::UseCase::Auth::Verify::ResetTokenTest
  class AppError < RuntimeError
    def self.invalid_params!(params)
      raise self, "invalid_params"
    end
    def self.invalid_account!(params)
      raise self, "invalid_account"
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

    def valid_reset_password_token?(params)
      @params[:valid_reset_password_token]
    end
  end

  describe Monban::UseCase::Auth::Verify::ResetToken do
    describe "encode account" do
      it "encode full account data with valid login info" do
        repository = Repository.new(
          valid_reset_password_token: true,
        )

        now = ::Time.now

        assert_nil(
          Monban::UseCase::Auth::Verify::ResetToken.new(
            error: AppError,
            time: Time.new(now),
            repository: repository,
          )
            .verify(
              account_id: 1,
              reset_token: "RESET",
            )
        )
      end

      it "failed if account_id not well-formed" do
        repository = Repository.new(
          valid_reset_password_token: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::ResetToken.new(
            error: AppError,
            time: Time.new(now),
            repository: repository,
          )
            .verify(
              account_id: nil,
              reset_token: "RESET",
            )
        end
      end

      it "failed if empty reset_token" do
        repository = Repository.new(
          valid_reset_password_token: true,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::ResetToken.new(
            error: AppError,
            time: Time.new(now),
            repository: repository,
          )
            .verify(
              account_id: 1,
              reset_token: "",
            )
        end
      end

      it "raise AppError when reset_token not found" do
        repository = Repository.new(
          valid_reset_password_token: false,
        )

        now = ::Time.now

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::ResetToken.new(
            error: AppError,
            time: Time.new(now),
            repository: repository,
          )
            .verify(
              account_id: 1,
              reset_token: "RESET",
            )
        end
      end
    end
  end
end
