require "test_helper"

require "monban/use_case/auth/change/password"

module Monban::UseCase::Auth::Change::PasswordTest
  class Repository
    attr_reader :result

    def transaction
      yield
    end

    def delete_reset_password_token(params)
    end

    def update_password_hash(params)
      @result = params
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

  class Password < Monban::Domain::Password::Creater
    def initialize
    end

    def create(password:)
      password
    end
  end

  describe Monban::UseCase::Auth::Change::Password do
    describe "change" do
      it "update account's password_hash" do
        now = ::Time.now

        repository = Repository.new

        Monban::UseCase::Auth::Change::Password.new(
          repository: repository,
          time: Time.new(now),
          password: Password.new,
        )
          .change(
            account_id: 1,
            password: "PASSWORD",
          )

        assert_equal(
          repository.result,
          {
            account_id: 1,
            password_hash: "PASSWORD",
            now: now,
          }
        )
      end

      it "failed if account_id not well-formed" do
        now = ::Time.now

        repository = Repository.new

        assert_raises do
          Monban::UseCase::Auth::Change::Password.new(
            repository: repository,
            time: Time.new(now),
            password: Password.new,
          )
            .change(
              account_id: nil,
              password: "PASSWORD",
            )
        end
      end

      it "failed if empty password" do
        now = ::Time.now

        repository = Repository.new

        assert_raises do
          Monban::UseCase::Auth::Change::Password.new(
            repository: repository,
            time: Time.new(now),
            password: Password.new,
          )
            .change(
              account_id: 1,
              password: "",
            )
        end
      end
    end
  end
end
