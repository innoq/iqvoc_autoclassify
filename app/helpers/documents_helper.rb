module DocumentsHelper

  def short_title(document, max_length=75)
    title = document.title
    return unless title
    if title.length > max_length
      return "#{title[0...(max_length - 3)]}..."
    else
      return title
    end
  end

  def augmented_fulltext(document) # TODO: rename
    trace = JSON.parse(document.classification_trace.trace) # NB: integer keys are actually strings

    label_ids = trace["label_index"].values.uniq
    label_ids += trace["compound_index"].values.uniq
    labels = Label::Base.where(:id => label_ids.uniq).select([:id, :value]) # XXX: database queries don't belong into helpers!?
    # label values by ID
    labels = labels.each_with_object({}) { |label, hsh| hsh[label.id] = label.value }

    return DocumentParser::German.new(document.content).sentences.map { |sentence| # simply assuming DE, for now -- XXX: repeated parsing inefficient
      sentence.map! { |word|
        normal_hash = Inflectional::Base.normalize(word)
        label_id = trace["label_index"][normal_hash.to_s]
        if label_id
          label = labels[label_id]
          compound_id = trace["compound_index"][label_id.to_s]
          hint = "label: #{label}"
          hint += " | compound form: #{labels[compound_id]}" if compound_id
          %Q(<span class="hint" title="#{h hint}">#{h word}</span>)
        else
          word
        end
      }
      %Q(<p>#{sentence.join(" ")}</p>)
    }.join("\n\n") # XXX: discards punctuation, line breaks etc.; should only replace matches in the original string
  end

end
