# frozen_string_literal: true

require 'base64'
require_relative 'secure_message'

## Token and Detokenize Authorization Information for register token
# Usage examples:
#  token = VerifyToken.create({ key: 'value', key2: 12 }, VerifyToken::ONE_MONTH)
#  VerifyToken.payload(token)   # => {"key"=>"value", "key2"=>12}
class VerifyToken
  # five minutes for debug testing
  FIVE_MINS = 5 * 60

  ONE_HOUR = 60 * 60
  ONE_DAY = ONE_HOUR * 24
  ONE_WEEK = ONE_DAY * 7
  ONE_MONTH = ONE_WEEK * 4
  ONE_YEAR = ONE_MONTH * 12

  class ExpiredTokenError < StandardError; end
  class InvalidTokenError < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs

  # Create a token from a Hash payload
  # default expiration set to 1 hour for debugging
  def self.create(payload, expiration = ONE_HOUR)
    contents = { 'payload' => payload, 'exp' => expires(expiration) }
    tokenize(contents)
  end

  # Extract data from token
  def self.payload(token)
    contents = detokenize(token)
    expired?(contents) ? raise(ExpiredTokenError) : contents['payload']
  end

  # Tokenize contents or return nil if no data
  def self.tokenize(message)
    return nil unless message

    # change function name
    # change base_encrypt from API securable to encrypt from APP secure_message extension
    SecureMessage.encrypt(message)
  end

  # Detokenize and return contents, or raise error
  def self.detokenize(ciphertext64)
    return nil unless ciphertext64

    # change function name
    # change base_decrypt from API securable to decrypt from APP secure_message extension
    SecureMessage.decrypt(ciphertext64)
  rescue StandardError
    raise InvalidTokenError
  end

  def self.expires(expiration)
    (Time.now + expiration).to_i
  end

  def self.expired?(contents)
    Time.now > Time.at(contents['exp'])
  rescue StandardError
    raise InvalidTokenError
  end
end
