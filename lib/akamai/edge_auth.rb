require "akamai/edge_auth/version"
require "openssl"

module Akamai
  class EdgeAuth
    attr_accessor :key, :token_type, :token_name,
      :algorithm, :field_delimiter, :acl_delimiter

    ALLOWED_ALGORITHM = ['sha256', 'sha1', 'md5']

    def initialize(key: nil, token_type: "URL", token_name: "hdnts",
                   algorithm: "sha256", field_delimiter: "~", acl_delimiter: "!")

      raise EdgeAuthError, "no key provided" if key.nil? || key.length < 1
      raise EdgeAuthError, "algorithm must be one of 'sha256', 'sha1' or 'md5'" unless ALLOWED_ALGORITHM.include? algorithm

      @key = key
      @token_type = token_type
      @token_name = token_name
      @algorithm = algorithm
      @field_delimiter = field_delimiter
      @acl_delimiter = acl_delimiter
    end

    def generate_token(start_time: "now", end_time: nil, window_seconds: nil,
                       acl: nil, url: nil, ip: nil,
                       session_id: nil, payload: nil)
      raise EdgeAuthError, "no end_time or window_seconds is provided" if end_time.nil? && window_seconds.nil?
      raise EdgeAuthError, "you must provide an ACL or a URL." if (acl.nil? && url.nil?) || (acl && url)

      if start_time.to_s.downcase == "now"
        start_time = Time.now.getgm.to_i
      else
        begin
          start_time = 0 if start_time < 0
        rescue
          raise EdgeAuthError, "start_time must be UNIX timestamps or 'now'"
        end
      end

      if end_time
        begin
          end_time = 0 if end_time < 0
        rescue
          raise EdgeAuthError, "end_time must be UNIX timestamps."
        end
      end

      if window_seconds
        begin
          end_time = start_time + window_seconds
        rescue
          raise EdgeAuthError, "window_seconds must be numeric."
        end
      end

      if end_time <= start_time
        raise EdgeAuthError, "token will have already expired."
      end

      new_token = Array.new

      if ip
        new_token.push "ip=#{ip}"
      end

      new_token.push "st=#{start_time}"
      new_token.push "exp=#{end_time}"

      new_token.push "acl=#{acl}" unless acl.nil?

      if session_id
        new_token.push "id=#{session_id}"
      end

      if payload
        new_token.push "data=#{payload}"
      end

      hash_code = new_token.clone

      new_token.push "url=#{url}" unless url.nil?

      bin_key = Array(key.gsub(/\s/,'')).pack("H*")
      digest = OpenSSL::Digest.new(algorithm)
      token_hmac = OpenSSL::HMAC.new(bin_key, digest)
      token_hmac.update(hash_code.join(field_delimiter))

      new_token.push "hmac=#{token_hmac}"

      "#{@token_name}=#{new_token.join(@field_delimiter)}"
    end

    def escape_early(string)
      CGI::escape(string).gsub(/(%..)/) {$1.downcase}
    end
  end

  class EdgeAuthError < StandardError
    def initialize(msg = "StandardError")
      super
    end
  end
end
