module DocumentsHelper
  def classification_augmentation(document, classifications, classification) # XXX: bad API
    return augmented_classifications(document, classifications)[classification.id]
  end

  # XXX: all this is probably _way_ more complex than it needs to be
  def augmented_classifications(document, classifications) # XXX: rename (misleading; only returns details)
    return @augmented_classifications if @augmented_classifications
    trace = get_trace(document)

    # invert concept index; list of label IDs by concept ID
    index = trace['concept_index'].each_with_object({}) { |data, hsh|
      label_id, concept_ids = data
      concept_ids.each { |id|
        hsh[id] ||= []
        hsh[id] << label_id.to_i # trace's integer keys are actually strings (due to JSON)
      }
    }

    # list of labelings by concept ID
    labelings = Labeling::Base.where(owner_id: index.keys). # XXX: database queries don't belong into helpers!?
        select([:type, :owner_id, :target_id])
    labelings = labelings.each_with_object({}) { |ln, hsh|
      hsh[ln.owner_id] ||= []
      hsh[ln.owner_id] << ln
    }
    # FIXME: inefficient; duplicates `augmented_fulltext` functionality
    label_ids = (trace['label_index']).values.flatten
    label_ids+= (trace['result_index']).values.flatten
    labels = Iqvoc::XLLabel.base_class.# XXX: database queries don't belong into helpers!?
        where(id: label_ids.uniq, language: I18n.locale).
        select([:id, :origin, :value, :language])
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
      hsh[classification.id] = content_tag(:div, {class: 'details'}) do
        label_index[classification.concept_id].map { |type, labels|
          caption = type.constantize.model_name.human(count: 2)
          render_ulist(caption, labels) do |label|
            uri = label_path(id: label.origin)
            link_to(label.to_s, uri)
          end
        }.join("\n").html_safe
      end
    }
  end

  def augmented_fulltext(document)
    trace = get_trace(document)
    label_ids = trace.map { |_, v| v.values }.flatten.uniq

    labels = Iqvoc::XLLabel.base_class.# XXX: database queries don't belong into helpers!!
    where(id: label_ids, language: I18n.locale).
        select([:id, :origin, :value, :language])
    # labels by ID
    labels = labels.each_with_object({}) { |label, hsh| hsh[label.id] = label }

    return trace['result_index'].map { |sentence_key, _|

      # ROW: Original Sentence (more or less original)
      segment = [%Q(<h5>#{h sentence_key}</h5>)]

      # ROW: All given regular labels
      segment << trace['label_index'][sentence_key].map { |label_id|
        label = labels[label_id]

        if label
          classes = ['hint']
          details = [
              "<h3>#{label.class.model_name.human(count: 1)}</h3>",
              link_to(label.to_s, label_path(id: label.origin))
          ]

          %Q(<span class="#{classes.join ' '}">#{h label}</span>) +
              %Q(<div class="details">#{details.join("\n")}</div>)
        end
      }
      segment << "\n\n"

      # ROW: All resulting labels
      segment << trace['result_index'][sentence_key].map { |label_id|
        label = labels[label_id]
        #pp "LABEL: #{label_id} -> #{label}"

        if label
          classes = ['hint']
          details = [
              "<h3>#{label.class.model_name.human(count: 1)}</h3>",
              link_to(label.to_s, label_path(id: label.origin))
          ]

          if trace['phrase_index'][sentence_key].include? label_id
            classes << 'compounds'
            caption = "#{CompoundForm::Base.model_name.human(count: 1)} (Phrase)"
            compound_ids = CompoundForm::Base.where(domain_id: label_id).first().compound_form_contents.map(&:label_id) # XXX: database queries don't belong into helpers!!
            details << render_olist(caption, compound_ids.uniq) do |id| # TODO: i18n
              uri = label_path(id: labels[id].origin)
              link_to(labels[id].to_s, uri)
            end
          end

          if trace['compound_index'][sentence_key].include? label_id
            classes << 'compounds'
            caption = "#{CompoundForm::Base.model_name.human(count: 1)}"
            compound_ids = CompoundForm::Base.where(domain_id: label_id).first().compound_form_contents.map(&:label_id) # XXX: database queries don't belong into helpers!!
            details << render_olist(caption, compound_ids.uniq) do |id| # TODO: i18n
              uri = label_path(id: labels[id].origin)
              link_to(labels[id].to_s, uri)
            end
          end

          if trace['homograph_index'][sentence_key].include? label_id
            classes << 'compounds'
            caption = '(Homograph)'
            details << caption
          end

          concepts = trace['concept_index'][label_id.to_s]
          if concepts
            concepts = Iqvoc::Concept.base_class.where(id: concepts) # XXX: database queries don't belong into helpers!?
            concepts = concepts.index_by(&:id)
            classes << 'concepts'
            caption = concepts.first.last.class.model_name.human(count: 2)
            details << render_ulist(caption, concepts) do |id, concept|
              uri = concept_path(id: concept.origin)
              link_to(concept.to_s, uri) # XXX: `to_s` is expensive (label loaded lazily)
            end
          end

          %Q(<span class="#{classes.join ' '}">#{h label}</span>) +
              %Q(<div class="details">#{details.join("\n")}</div>)
        end
      }

      content_tag(:div, segment.join(' ').html_safe, {class: 'sentence'})
    }.join("\n\n")
  end

  def render_ulist(caption, items, &block)
    caption = "<h4>#{h caption}</h4>"
    list = content_tag :ul do
      items.map { |item|
        content_tag :li, yield(item)
      }.join("\n").html_safe
    end
    return caption + list
  end

  def render_olist(caption, items, &block)
    caption = "<h4>#{h caption}</h4>"
    list = content_tag :ol do
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
