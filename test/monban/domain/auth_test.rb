require "test_helper"

require "monban/domain/auth"

module Monban::Domain::AuthTest
  class Time
    def initialize(now)
      @now = now
    end

    def now
      @now
    end
  end

  describe Monban::Domain::Auth do
    describe "encode jwt" do
      it "encode full jwt" do
        now = ::Time.now

        assert_equal(
          Monban::Domain::Auth::Encoder.new(
            jwt_service: "SERVICE",
            jwt_secret:  "SECRET",
            jwt_algorithm: "HS512",
            time: Time.new(now)
          )
            .full(
              public_id: "PUBLIC_ID",
              roles: ["user","system"],
              expired_at: now + 10,
            ),

          JWT.encode(
            {
              iss: "full@SERVICE",
              iat: now.to_i,
              exp: (now + 10).to_i,

              sub: "PUBLIC_ID",
              aud: ["user","system"],
            },
            "SECRET",
            "HS512"
          )
        )
      end

      it "encode authy jwt with registered authy_id" do
        now = ::Time.now

        assert_equal(
          Monban::Domain::Auth::Encoder.new(
            jwt_service: "SERVICE",
            jwt_secret:  "SECRET",
            jwt_algorithm: "HS512",
            time: Time.new(now)
          )
            .authy(
              public_id: "PUBLIC_ID",
              authy_id: 1,
              expired_at: now + 10,
            ),

          JWT.encode(
            {
              iss: "authy@SERVICE",
              iat: now.to_i,
              exp: (now + 10).to_i,

              sub: "PUBLIC_ID",
              aud: "registered",
            },
            "SECRET",
            "HS512"
          )
        )
      end

      it "encode authy jwt with unregistered authy_id" do
        now = ::Time.now

        assert_equal(
          Monban::Domain::Auth::Encoder.new(
            jwt_service: "SERVICE",
            jwt_secret:  "SECRET",
            jwt_algorithm: "HS512",
            time: Time.new(now)
          )
            .authy(
              public_id: "PUBLIC_ID",
              authy_id: nil,
              expired_at: now + 10,
            ),

          JWT.encode(
            {
              iss: "authy@SERVICE",
              iat: now.to_i,
              exp: (now + 10).to_i,

              sub: "PUBLIC_ID",
              aud: "unregistered",
            },
            "SECRET",
            "HS512"
          )
        )
      end

      it "encode reset jwt" do
        now = ::Time.now

        assert_equal(
          Monban::Domain::Auth::Encoder.new(
            jwt_service: "SERVICE",
            jwt_secret:  "SECRET",
            jwt_algorithm: "HS512",
            time: Time.new(now)
          )
            .reset(
              public_id: "PUBLIC_ID",
              reset_token: "TOKEN",
              expired_at: now + 10,
            ),

          JWT.encode(
            {
              iss: "reset@SERVICE",
              iat: now.to_i,
              exp: (now + 10).to_i,

              sub: "PUBLIC_ID",
              aud: "TOKEN",
            },
            "SECRET",
            "HS512"
          )
        )
      end
    end

    describe "decode jwt with verify" do
      describe "decode full" do
        it "success with valid token" do
          now = ::Time.now

          assert_equal(
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "full@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: ["user","system"],
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :full,
                roles: [:user],
              ),

            {
              public_id: "8-LENGTH",
              roles: ["user","system"],
            }
          )
        end

        it "failed if public_id length unmatched" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "full@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH?",
                    aud: ["user","system"],
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :full,
                roles: [:user],
              )
          end
        end

        it "failed if unknown role detected" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "full@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: ["user","system","unknown"],
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :full,
                roles: [:user],
              )
          end
        end
      end

      describe "decode authy" do
        it "success with valid token" do
          now = ::Time.now

          assert_equal(
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "authy@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: "registered",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :authy,
                roles: {only_registered: true},
              ),

            {
              public_id: "8-LENGTH",
            }
          )
        end

        it "success with unregistered token" do
          now = ::Time.now

          assert_equal(
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "authy@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: "unregistered",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :authy,
                roles: {only_registered: false},
              ),

            {
              public_id: "8-LENGTH",
            }
          )
        end

        it "failed if unregistered with only_registered" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "authy@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: "unregistered",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :authy,
                roles: {only_registered: true},
              )
          end
        end

        it "failed if unknown aud" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "authy@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: "unknown",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :authy,
                roles: {only_registered: false},
              )
          end
        end

        it "failed if public_id length unmatched" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "authy@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH?",
                    aud: "registered",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :authy,
                roles: {only_registered: true},
              )
          end
        end
      end

      describe "decode reset" do
        it "success with valid token" do
          now = ::Time.now

          assert_equal(
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "reset@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: "10--LENGTH",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :reset,
                roles: nil,
              ),

            {
              public_id:   "8-LENGTH",
              reset_token: "10--LENGTH",
            }
          )
        end

        it "failed if public_id length unmatched" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "reset@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH?",
                    aud: "10--LENGTH",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :reset,
                roles: [],
              )
          end
        end

        it "failed if reset_token length unmatched" do
          now = ::Time.now

          assert_raises Monban::Domain::Auth::DecodeError do
            Monban::Domain::Auth::Decoder.new(
              jwt_service: "SERVICE",
              jwt_secret:  "SECRET",
              jwt_algorithm: "HS512",
              public_id_length: 8,
              reset_token_length: 10,
              all_roles: [:user,:system],
              allow_full_access: [:admin],
            )
              .decode(
                JWT.encode(
                  {
                    iss: "reset@SERVICE",
                    iat: now.to_i,
                    exp: (now + 10).to_i,

                    sub: "8-LENGTH",
                    aud: "10--LENGTH?",
                  },
                  "SECRET",
                  "HS512"
                ),
                type: :reset,
                roles: []
              )
          end
        end
      end

      it "failed with invalid type" do
        now = ::Time.now

        assert_raises Monban::Domain::Auth::SettingError do
          Monban::Domain::Auth::Decoder.new(
            jwt_service: "SERVICE",
            jwt_secret:  "SECRET",
            jwt_algorithm: "HS512",
            public_id_length: 8,
            reset_token_length: 10,
            all_roles: [:user,:system],
            allow_full_access: [:admin],
          )
            .decode(
              JWT.encode(
                {
                  iss: "full@SERVICE",
                  iat: now.to_i,
                  exp: (now + 10).to_i,

                  sub: "8-LENGTH",
                  aud: ["user","system"],
                },
                "SECRET",
                "HS512"
              ),
              type: :unknown,
              roles: [:user],
            )
        end
      end
    end

    describe "authorized account encode/decode" do
      it "success encode" do
        authorized = Monban::Domain::Auth::Authorized.new(
          authorized_secret: "SECRET",
          authorized_algorithm: "HS512",
        )

        assert_equal(
          authorized.encode({ account_id: 1 }),
          JWT.encode(
            { account_id: 1 },
            "SECRET",
            "HS512",
          )
        )
      end

      it "success decode" do
        authorized = Monban::Domain::Auth::Authorized.new(
          authorized_secret: "SECRET",
          authorized_algorithm: "HS512",
        )

        token = JWT.encode(
          { account_id: 1 },
          "SECRET",
          "HS512",
        )

        assert_equal(
          authorized.decode(token),
          { "account_id" => 1 },
        )
      end

      it "decode error with invalid token" do
        authorized = Monban::Domain::Auth::Authorized.new(
          authorized_secret: "SECRET",
          authorized_algorithm: "HS512",
        )

        assert_raises Monban::Domain::Auth::DecodeError do
          authorized.decode("TOKEN")
        end
      end
    end

  end
end
