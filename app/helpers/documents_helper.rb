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

  def classification_augmentation(document, classifications, classification) # XXX: bad API
    return augmented_classifications(document, classifications)[classification.id]
  end

  # XXX: all this is probably _way_ more complex than it needs to be
  def augmented_classifications(document, classifications) # XXX: rename (misleading; only returns details)
    return @augmented_classifications if @augmented_classifications
    trace = get_trace(document)

    # invert concept index; list of label IDs by concept ID
    index = trace["concept_index"].each_with_object({}) { |data, hsh|
      label_id, concept_ids = data
      concept_ids.each { |id|
        hsh[id] ||= []
        hsh[id] << label_id.to_i # trace's integer keys are actually strings (due to JSON)
      }
    }

    # list of labelings by concept ID
    labelings = Labeling::Base.where(:owner_id => index.keys). # XXX: database queries don't belong into helpers!?
        select([:type, :owner_id, :target_id])
    labelings = labelings.each_with_object({}) { |ln, hsh|
      hsh[ln.owner_id] ||= []
      hsh[ln.owner_id] << ln
    }

    # FIXME: inefficient; duplicates `augmented_fulltext` functionality
    label_ids = trace["label_index"].values.uniq
    label_ids += trace["compound_index"].values.uniq
    labels = Iqvoc::XLLabel.base_class.where(:id => label_ids.uniq).
        select([:id, :origin, :value, :language]) # XXX: database queries don't belong into helpers!?
    # labels by ID
    labels = labels.each_with_object({}) { |label, hsh| hsh[label.id] = label }

    # list of labels by concept ID by labeling type
    label_index = classifications.each_with_object({}) { |classification, hsh|
      concept_id = classification.concept_id
      hsh[concept_id] = labelings[concept_id].each_with_object({}) { |ln, obj|
        # list of label IDs by labeling type
        if index[concept_id].include?(ln.target_id) # NB: relevant labels only
          obj[ln.type] ||= []
          obj[ln.type] << labels[ln.target_id]
        end
      }
    }

    return @augmented_classifications = classifications.each_with_object({}) { |classification, hsh|
      hsh[classification.id] = content_tag(:div, { :class => "details" }) do
        label_index[classification.concept_id].map { |type, labels|
          render_list("Label (#{type})", labels) do |label| # TODO: i18n
            uri = label_path(:id => label.origin)
            link_to(label.to_s, uri)
          end
        }.join("\n").html_safe
      end
    }
  end

  def augmented_fulltext(document)
    trace = get_trace(document)

    label_ids = trace["label_index"].values.uniq
    label_ids += trace["compound_index"].values.uniq
    labels = Iqvoc::XLLabel.base_class.where(:id => label_ids.uniq).
        select([:id, :origin, :value, :language]) # XXX: database queries don't belong into helpers!?
    # labels by ID
    labels = labels.each_with_object({}) { |label, hsh| hsh[label.id] = label }

    return DocumentParser::German.new(document.content).sentences.map { |sentence| # simply assuming DE, for now -- XXX: repeated parsing inefficient
      sentence.map! { |word|
        normal_hash = Inflectional::Base.normalize(word)
        label_id = trace["label_index"][normal_hash.to_s]

        if label_id
          label = labels[label_id]
          classes = ["hint"]
          details = [
            "<h3>Label</h3>", # TODO: i18n
            link_to(label.to_s, label_path(:id => label.origin))
          ]

          compound_ids = trace["compound_index"][label_id.to_s]
          if compound_ids
            classes << "compounds"
            details << render_list("Compound Forms", compound_ids.uniq) do |id| # TODO: i18n
              label = labels[id]
              uri = label_path(:id => label.origin)
              link_to(label.to_s, uri)
            end
          end

          concept_ids = trace["concept_index"][label_id.to_s]
          if concept_ids
            classes << "concepts"
            details << render_list("Concepts", concept_ids) do |id| # TODO: i18n
              concept = Iqvoc::Concept.base_class.find(id) # FIXME: inefficient; should do batch retrieval -- XXX: database queries don't belong into helpers!?
              uri = concept_path(:id => concept.origin)
              link_to(concept.to_s, uri) # XXX: `to_s` is expensive (label loaded lazily)
            end
          end

          %Q(<span class="#{classes.join " "}">#{h word}</span>) +
              %Q(<div class="details">#{details.join("\n")}</div>)
        else
          word
        end
      }
      content_tag(:div, sentence.join(" ").html_safe, { :class => "sentence" })
    }.join("\n\n") # XXX: discards punctuation, line breaks etc.; should only replace matches in the original string
  end

  def render_list(caption, items, &block)
    caption = "<h3>#{h caption}</h3>"
    list = content_tag :ul do
      items.map { |item|
        content_tag :li, yield(item)
      }.join("\n").html_safe
    end
    return caption + list
  end

  def get_trace(document) # NB: integer keys are actually strings (due to JSON)
    # NB: `@trace` already used in template
    return @tracedata ||= JSON.parse(document.classification_trace.trace)
  end

end
