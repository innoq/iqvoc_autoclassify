module Document
  module Autoclassify2
    class Plain < Document::Plain

      def concepts
        return @concepts if @concepts
        @concepts = self.determine_concepts
        # self.analyze_concept_relations
        @concepts
      end

      def determine_concepts
        call_autoclassify_service

        concepts = {}
        results = Array(self.api_response_body && self.api_response_body['results'])
        preloaded_concepts = classifiable_concepts(results.map { |item| concept_origin_of(item) })

        results.each do |item|
          concept = preloaded_concepts[concept_origin_of(item)]
          # the service index is a snapshot and does not filter by publication
          # state, so it may report concepts we must not classify against
          next unless concept

          concepts[concept] ||= [item["score"]]
        end

        concepts
      end

      private

      def concept_origin_of(item)
        item["uri"].to_s.split('/').last
      end

      # only concepts eligible for classification -- mirrors the filtering done
      # in Document::Base#determine_concepts for the classic algorithm
      def classifiable_concepts(origins)
        Iqvoc::Concept.base_class.
          where(origin: origins, auto_classify: true).
          published.
          not_expired.
          index_by(&:origin)
      end

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
