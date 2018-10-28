require "test_helper"

require "monban/domain/password"

module Monban::Domain::PasswordTest
  class Creater
    def create(password:)
      password
    end
  end

  class Checker
    def hash_secret(password:, salt:)
      password
    end
  end

  class Digest
    def call(params)
      "digest:#{params}"
    end
  end

  describe Monban::Domain::Password do
    describe "create" do
      it "create password_hash with specific params" do
        password_hash =
          Monban::Domain::Password::Creater.new(
            password_creater: Creater.new,
            password_digest:  Digest.new,
            password_secret:  "SECRET",
          )
            .create(
              password: "PASSWORD",
            )

        assert_equal(
          password_hash.to_s,
          "digest:PASSWORDSECRET",
        )
      end
    end

    describe "hash_secret" do
      it "hash password by secret with specific params" do
        assert_equal(
          Monban::Domain::Password::Checker.new(
            password_checker: Checker.new,
            password_digest:  Digest.new,
            password_secret:  "SECRET",
          )
            .hash_secret(
              password: "PASSWORD",
              salt:     "SALT",
            ),

          "digest:PASSWORDSECRET"
        )
      end
    end
  end
end
