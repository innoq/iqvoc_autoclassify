module Document
  module Autoclassify2
    class Plain < Document::Plain

      def concepts
        return @concepts if (@concepts && @trace)
        @concepts = self.determine_concepts
        # self.analyze_concept_relations
        @concepts
      end

      def determine_concepts
        call_autoclassify_service

        concepts = {}
        concept_origins = self.api_response_body['results'].map { it["uri"]}.map { it.split('/').last }
        preloaded_concepts = Iqvoc::Concept.base_class.where(origin: concept_origins)

        self.api_response_body['results'].each do |item|
          concept_origin = item["uri"].split('/').last
          concept = preloaded_concepts.find { |c| c.origin == concept_origin }
          concepts[concept] ||= [item["score"]]

          concepts
        end

        concepts
      end

      private

      def call_autoclassify_service
        service = AutoclassifyApiService.new

        response = service.classify_content(
          content: self.content,
          language: self.language,
          title: self.title
        )

        self.api_response_body = response
        self.update(api_response_body: response) if persist?
      end

    end
  end
end
