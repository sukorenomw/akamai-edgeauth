require "spec_helper"

RSpec.describe Akamai::EdgeAuth do
  context "versioning" do
    it "has a version number" do
      expect(Akamai::EdgeAuth::VERSION).not_to be nil
    end
  end

  describe "#initialize" do
    context "when key is not provided" do
      it "will raise Akamai::EdgeAuthError" do
        expect{
          Akamai::EdgeAuth.new()
        }.to raise_error(Akamai::EdgeAuthError, "no key provided")
      end
    end

    context "when key is provided" do
      context "when key length is less than 1" do
        it "will raise Akamai::EdgeAuthError" do
          expect{
            Akamai::EdgeAuth.new(key: "")
          }.to raise_error(Akamai::EdgeAuthError, "no key provided")
        end
      end

      context "when default params are not provided" do
        it "will assign default value" do
          edge_auth = Akamai::EdgeAuth.new(key: "somekeyhere")

          expect(edge_auth.token_type).to eq "URL"
          expect(edge_auth.token_name).to eq "hdnts"
          expect(edge_auth.algorithm).to eq "sha256"
          expect(edge_auth.field_delimiter).to eq "~"
          expect(edge_auth.acl_delimiter).to eq "!"
        end
      end
    end

    context "when algorithm is not one of 'sha256', 'sha1' or 'md5' " do
      it "will raise EdgeAuthError" do
        expect{
          Akamai::EdgeAuth.new(key: "somekeyhere",
                               algorithm: "BCrypt")
        }.to raise_error(Akamai::EdgeAuthError, "algorithm must be one of 'sha256', 'sha1' or 'md5'")

      end
    end
  end

  describe "#escape_early" do
    it "will escape token string" do
      edge_auth = Akamai::EdgeAuth.new(key: "somekeyhere")

      expect(edge_auth.escape_early("&hdnts=asdf")).to eq "%26hdnts%3dasdf"
    end
  end

  describe "#generate_token" do
    let(:edge_auth){ Akamai::EdgeAuth.new(key: "somekeyhere") }

    context "when end_time or window_seconds is not provided" do
      it "will raise Akamai::EdgeAuthError" do
        expect{
          edge_auth.generate_token()
        }.to raise_error(Akamai::EdgeAuthError, "no end_time or window_seconds is provided")
      end
    end

    context "acl and url" do
      it "raise EdgeAuthError when no acl or url provided" do
        expect{
          edge_auth.generate_token(window_seconds: 10)
        }.to raise_error(Akamai::EdgeAuthError, "you must provide an ACL or a URL.")
      end

      it "raise EdgeAuthError when acl and url are both provided" do
        expect{
          edge_auth.generate_token(window_seconds: 10, acl: "acl", url: "url")
        }.to raise_error(Akamai::EdgeAuthError, "you must provide an ACL or a URL.")
      end
    end

    context "when start_time is not provided" do
      before { Timecop.freeze(2017, 10, 10) }
      after { Timecop.return }

      context "with window_second" do
        let(:token) { edge_auth.generate_token(window_seconds: 30, acl: "acl") }
        let(:mocked_start_time) { Time.now.getgm.to_i }
        let(:mocked_end_time) { mocked_start_time + 30 }

        it "will set to now (current timestamp)" do
          expect(token).to match /st=#{mocked_start_time}/
        end

        it "will set expiration time from start_time + window_seconds" do
          expect(token).to match /exp=#{mocked_end_time}/
        end
      end
    end

    context "when start_time is provided" do
      context "when start_time is not in unix timestamp" do
        it "will raise EdgeAuthError" do
          expect{
            edge_auth.generate_token(start_time: "asdf",
                                     window_seconds: 10,
                                     acl: "acl")
          }.to raise_error(Akamai::EdgeAuthError, "start_time must be UNIX timestamps or 'now'")
        end
      end
    end

    context "when window_seconds is not numeric" do
      it "will raise EdgeAuthError" do
        expect{
          edge_auth.generate_token(window_seconds: "10", acl: "acl")
        }.to raise_error(Akamai::EdgeAuthError, "window_seconds must be numeric.")
      end
    end

    context "when window_seconds is less than zero" do
      it "raise EdgeAuthError" do
        expect{
          edge_auth.generate_token(window_seconds: -100, acl: "acl")
        }.to raise_error(Akamai::EdgeAuthError, "token will have already expired.")
      end
    end

    context "when end_time is not UNIX timestamps" do
      it "will raise EdgeAuthError" do
        expect{
          edge_auth.generate_token(end_time: "asdf", acl: "acl")
        }.to raise_error(Akamai::EdgeAuthError, "end_time must be UNIX timestamps.")
      end
    end

    context "when end_time is less than start_time" do
      let(:token) { edge_auth.generate_token(end_time: 30, acl: "acl") }

      it "raise EdgeAuthError" do
        expect{
          token
        }.to raise_error(Akamai::EdgeAuthError, "token will have already expired.")
      end
    end
  end
end
