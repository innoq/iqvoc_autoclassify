class FreeClassificationController < ApplicationController

  def index
    @suggestions = if params[:query]&.present? && params[:query].size >= 2
                     single_query(search_params.to_h.with_indifferent_access)
                   else
                     flash[:info] = t('txt.views.free_classification.query_input_too_short') if params[:query] && params[:query].size < 2
                     []
                   end

    @selected = search_params[:concepts] || []
    @results = Iqvoc::Concept.base_class.where('concepts.origin IN (?)', @selected) || []
    @free_classification_params = {
        query: search_params[:query],
        include_alt_labels: search_params[:include_alt_labels],
        include_used_for_labels: search_params[:include_used_for_labels],
        include_translations: search_params[:include_translations]
    }

    respond_to do |format|
      format.html {
        if request.headers['Accept'] == 'text/html; fragment=true'
          render template: 'free_classification/_suggestion_list', layout: false
        else
          render :index, layout: with_layout?
        end
      }
    end
  end

  private

  def search_params
    params.permit(:query, :include_translations, :include_alt_labels, :include_used_for_labels, :concepts => [])
  end

  def single_query(params = {})
    labeling_types = build_labeling_types(params)

    scope = Labeling::SKOSXL::Base.includes(:target)
                .where(type: labeling_types)
                .references(:labels, :concepts)
                .joins(:target)
                .order(Arel.sql("LENGTH(#{Label::Base.table_name}.value), #{Label::Base.table_name}.value ASC"))

    # exclude concepts belonging to Ordnungsdeskriptoren collection
    od_collection = Iqvoc::Collection.base_class.includes(:members).find_by(origin: 'OD')
    if od_collection
      od_concept_ids = od_collection.members.map(&:target_id)
    end

    # target concepts
    concepts = Iqvoc::Concept.base_class
                   .where(top_term: false)
                   .where.not(id: od_concept_ids)
                   .published
                   .not_expired
    scope = scope.includes(:owner).merge(concepts)

    # filter by query input
    query_str = build_query_string(params.merge(query_type: 'contains'))
    languages = build_language_query(params)

    labels = Iqvoc::XLLabel.base_class.by_query_value(query_str)
                 .by_language(languages)
                 .published
    scope = scope.merge(labels)

    scope
  end

  def build_language_query(options = {})
    res = ['de']
    res << 'en' if options['include_translations'] == 'true'
    res
  end

  def build_labeling_types(options = {})
    res = [ Iqvoc::Concept.pref_labeling_class_name ] # should be search in any case
    res << Iqvoc::Concept.alt_labeling_class_name if options[:include_alt_labels] == 'true'
    res << Labeling::UMT::UsedForLabel.name if options[:include_used_for_labels] == 'true'
    res
  end

  def build_query_string(params = {})
    query_str = params[:query]
    query_str = "%#{query_str}" if ['contains', 'ends_with'].include?(params[:query_type].to_s)
    query_str = "#{query_str}%" if ['contains', 'begins_with'].include?(params[:query_type].to_s)
    # Note that 'contains' will add an '%' to the beginning AND to the end

    query_str
  end
end
