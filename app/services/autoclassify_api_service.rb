class AutoclassifyApiService
  BASE_URL = ENV['AUTOCLASSIFY_SERVICE_URI']

  class Error < StandardError; end
  class ValidationError < Error; end

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    end
  end


  def classify_content(content:, language: 'de', title: nil, max_results: 20, min_score: 0.0)
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
