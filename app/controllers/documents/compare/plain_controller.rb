module Documents
  module Compare
    class PlainController < Documents::PlainController

      before_action :authorize_comparison!, only: :create

      protected

      def set_document
        @document = Document::Compare::Plain.new document_params

        @document.persist = false unless current_user
      end

      def authorize_comparison!
        authorize! :use, :administration
      end

    end
  end
end
