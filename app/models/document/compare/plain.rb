module Document
  module Compare
    class Plain < Document::Plain

      def classify
        super
        run_comparison_classification
      end

      def comparison_unavailable?
        api_response_body.blank?
      end

      def comparison_results
        return [] if comparison_unavailable?
        api_response_body['results']
      end

      def shared_concept_origins
        return [] if comparison_unavailable?
        classic_origins = classifications.map(&:concept_origin)
        comparison_origins = comparison_results.map { |result| result['uri'].split('/').last }
        classic_origins & comparison_origins
      end

      def classic_only_classifications
        classifications.reject { |classification| shared_concept_origins.include?(classification.concept_origin) }
      end

      def shared_classifications
        classifications.select { |classification| shared_concept_origins.include?(classification.concept_origin) }
      end

      def sns_only_results
        comparison_results.reject { |result| shared_concept_origins.include?(result['uri'].split('/').last) }
      end

      def sns_result_for_origin(origin)
        comparison_results.find { |result| result['uri'].split('/').last == origin }
      end

      private

      def run_comparison_classification
        return if AutoclassifyApiService::BASE_URL.blank?

        service = AutoclassifyApiService.new

        response = service.classify_content(
          content: self.content,
          language: self.language,
          title: self.title
        )

        self.api_response_body = response
        self.update(api_response_body: response) if persist?
      rescue AutoclassifyApiService::Error
        nil
      end

    end
  end
end
