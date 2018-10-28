require "test_helper"

require "monban/use_case/account/admin"

module Monban::UseCase::Account::AdminTest
  class Time
    def initialize(now)
      @now = now
    end

    def now
      @now
    end
  end

  class Repository
    def initialize
      @result = {}
    end

    attr_reader :result

    def transaction
      yield
    end

    def reset_password_email_account(params)
    end

    def insert_account(params)
      @result[:insert_account] = params
      1
    end

    def update_roles(params)
      @result[:update_roles] = params
    end

    def update_reset_password_email(params)
      @result[:update_reset_password_email] = params
    end
  end

  describe Monban::UseCase::Account::Admin do
    describe "register admin account" do
      it "register admin account" do
        now = ::Time.now

        repository = Repository.new

        Monban::UseCase::Account::Admin.new(
          time:  Time.new(now),
          repository: repository,
          admin_email: "admin@example.com",
          admin_roles: [:admin],
        )
          .register

        assert_equal(
          repository.result,
          {
            insert_account: { now: now },
            update_roles: { account_id: 1, roles: [:admin], now: now },
            update_reset_password_email: { account_id: 1, email: "admin@example.com", now: now },
          }
        )
      end
    end
  end
end
