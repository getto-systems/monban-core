require "test_helper"

require "monban/use_case/auth/verify/password"

require "monban/core_test/app_error"

module Monban::UseCase::Auth::Verify::PasswordTest
  class AppError < Monban::CoreTest::AppError
  end

  class Repository
    def initialize(params)
      @params = params
    end

    def account_id_by_login_id(params)
      @params[:account_id]
    end

    def password_salt(params)
      @params[:password_salt]
    end

    def password_hash_match?(params)
      @params[:password_hash_match]
    end
  end

  class Password
    def hash_secret(params)
      params
    end
  end

  describe Monban::UseCase::Auth::Verify::Password do
    describe "encode account" do
      it "encode full account data with valid login info" do
        repository = Repository.new(
          account_id: 1,
          password_hash_match: true,
          password_salt: "salt",
        )

        assert_equal(
          Monban::UseCase::Auth::Verify::Password.new(
            error: AppError,
            password: Password.new,
            repository: repository,
          )
            .verify(
              login_id: "login_id",
              password: "password",
            ),

          1
        )
      end

      it "failed if empty login_id" do
        repository = Repository.new(
          account_id: 1,
          password_hash_match: true,
          password_salt: "salt",
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Password.new(
            error: AppError,
            password: Password.new,
            repository: repository,
          )
            .verify(
              login_id: "",
              password: "password",
            )
        end
      end

      it "failed if empty password" do
        repository = Repository.new(
          account_id: 1,
          password_hash_match: true,
          password_salt: "salt",
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Password.new(
            error: AppError,
            password: Password.new,
            repository: repository,
          )
            .verify(
              login_id: "login_id",
              password: "",
            )
        end
      end

      it "raise AppError when account not found" do
        repository = Repository.new(
          account_id: nil,
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Password.new(
            error: AppError,
            password: Password.new,
            repository: repository,
          )
            .verify(
              login_id: "login_id",
              password: "password",
            )
        end
      end

      it "raise AppError when password salt not exist" do
        repository = Repository.new(
          account_id: 1,
          password_salt: nil,
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Password.new(
            error: AppError,
            password: Password.new,
            repository: repository,
          )
            .verify(
              login_id: "login_id",
              password: "password",
            )
        end
      end

      it "raise AppError when password not match" do
        repository = Repository.new(
          account_id: 1,
          password_hash_match: false,
          password_salt: "salt",
        )

        assert_raises AppError do
          Monban::UseCase::Auth::Verify::Password.new(
            error: AppError,
            password: Password.new,
            repository: repository,
          )
            .verify(
              login_id: "login_id",
              password: "password",
            )
        end
      end
    end
  end
end
