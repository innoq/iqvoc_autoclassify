class Label::Iqvoc::Properties::AutoClassify
  class_attribute :rdf_namespace, :rdf_predicate
  self.rdf_namespace = 'iqvoc'
  self.rdf_predicate = 'autoClassify'

  def self.build_from_rdf(rdf_subject, rdf_predicate, rdf_object)
    unless rdf_object =~ RDFAPI::LITERAL_REGEXP
      raise InvalidStringLiteralError,
        "#{self.name}#build_from_rdf: Object (#{rdf_object}) must be a string literal"
    end

    value = begin
      JSON.parse(%Q{["#{$1}"]})[0].gsub('\\n', "\n") # Trick to decode \uHHHHH chars
    rescue JSON::ParserError
      $1
    end

    if value.casecmp('true') || value.casecmp('1')
      rdf_subject.update_attributes(auto_classify: true)
    else
      rdf_subject.update_attributes(auto_classify: false)
    end
  end
end
