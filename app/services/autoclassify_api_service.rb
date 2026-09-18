class AutoclassifyApiService
  BASE_URL = ENV['AUTOCLASSIFY_SERVICE_URI']
  REQUEST_TIMEOUT = 5 # seconds

  class Error < StandardError; end
  class ValidationError < Error; end

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.response :raise_error
      faraday.options.timeout = REQUEST_TIMEOUT
      faraday.options.open_timeout = REQUEST_TIMEOUT
      faraday.adapter Faraday.default_adapter
    end
  end


  # max_results asks for as much as the service allows, so the weaker end of the
  # result list stays visible while the classification is being evaluated. The
  # cut is by count alone -- min_score 0.0 filters nothing out.
  def classify_content(content:, language: 'de', title: nil, max_results: 100, min_score: 0.0)
    validate_params!(content, language, title, max_results, min_score)

    payload = {
      language: language,
      content: content,
      output: {
        max_results: max_results,
        min_score: min_score
      }
    }
    payload[:title] = title if title.present?

    response = @connection.post('/autoclassify/content', payload)
    response.body
  rescue Faraday::Error => e
    raise Error, "API request failed: #{e.message}"
  end

  private

  def validate_params!(content, language, title, max_results, min_score)
    raise ValidationError, 'Content missing' if content.blank?
    raise ValidationError, 'Unknown language' unless %w[de en].include?(language)
    raise ValidationError, 'max_results out of range (1-100)' unless (1..100).cover?(max_results)
    raise ValidationError, 'min_score out of range (0.0-1.0)' unless (0.0..1.0).cover?(min_score)
  end
end
