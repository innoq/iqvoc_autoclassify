module Documents
  module Autoclassify2
    class PlainController < Documents::PlainController

      protected

      def set_document
        @document = Document::Autoclassify2::Plain.new document_params

        @document.persist = false unless current_user
      end

    end

  end
end
