class Link < ApplicationRecord
  has_secure_password validations: false

  # Validations
  validates :url, presence: true,
                  format: {
                    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                    message: "must be a valid HTTP/HTTPS URL"
                  }

  validates :code, presence: true,
                   uniqueness: true,
                   length: { is: 8 }

  validate :validate_url_security
  validate :validate_url_availability, if: -> { url.present? && errors[:url].none? }
  validate :expires_at_must_be_in_future, if: -> { expires_at.present? }

  # Callbacks
  before_validation :normalize_url
  before_validation :generate_unique_code, on: :create

  def to_param
    code
  end

  def to_json(*)
    {
      original_url: url,
      short_url: short_url,
      created_at: created_at,
      expires_at: expires_at,
      code: code,
      clicks: clicks
    }.to_json
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def short_url
    Rails.application.routes.url_helpers.redirect_url(code)
  end

  private

  def normalize_url
    return if url.blank?

    begin
      uri = Addressable::URI.parse(url).normalize
      self.url = uri.to_s
    rescue Addressable::URI::InvalidURIError => e
      errors.add(:url, "contains invalid characters or format", e.message)
    end
  end

  def generate_unique_code
    self.code ||= loop do
      random_code = SecureRandom.alphanumeric(8)
      break random_code unless self.class.exists?(code: random_code)
    end
  end

  def validate_url_security
    return if errors[:url].any?

    uri = URI.parse(url)
    errors.add(:url, "must use HTTPS protocol") unless uri.scheme == "https"
  rescue URI::InvalidURIError
    # Already handled by format validation
  end

  def validate_url_availability
    response = Faraday.head(url) do |req|
      req.options.open_timeout = 3
      req.options.timeout = 5
    end

    unless response.success? || response.status == 301 || response.status == 302
      errors.add(:url, "could not be verified (HTTP #{response.status})")
    end
  rescue Faraday::Error => e
    errors.add(:url, "could not be reached: #{e.message}")
  end

  def expires_at_must_be_in_future
    errors.add(:expires_at, "must be in the future") if expires_at <= Time.current
  end
end
