class FreeClassificationController < ApplicationController

  def index
    suggestion_params = {:languages=>['de', 'en'], :query_type=>'contains'}
    @suggestions = if params[:query]&.present? && params[:query].size >= 2
                     single_query(suggestion_params.merge(search_params).symbolize_keys)
                   else
                     flash[:info] = t('txt.views.free_classification.query_input_too_short')
                     []
                   end

    @selected = search_params[:concepts] || []
    @results = Iqvoc::Concept.base_class.where('concepts.origin IN (?)', @selected) || []

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
    params.permit(:query, :concepts => [])
  end

  def single_query(params = {})
    query_str = build_query_string(params)

    scope = Labeling::SKOSXL::Base.includes(:target)
                .references(:labels, :concepts)
                .joins(:target)
                .order(Arel.sql("LENGTH(#{Label::Base.table_name}.value), #{Label::Base.table_name}.value ASC"))

    # target concepts
    concepts = Iqvoc::Concept.base_class
                   .where(top_term: false)
                   .published
                   .not_expired
    scope = scope.includes(:owner).merge(concepts)

    # filter by query input
    labels = Iqvoc::XLLabel.base_class.by_query_value(query_str)
                 .by_language(params[:languages].to_a)
                 .published
    scope = scope.merge(labels)

    # TODO: exclude concepts belonging to Ordnungsdeskriptoren collection?
    # collection = Iqvoc::Collection.base_class.find_by(origin: 'OD')
    # if collection
    #   scope = scope.includes(owner: {collection_members: :collection})
    #   scope = scope.where.not("#{Collection::Member::Base.table_name}.collection_id" => collection.id)
    # end

    scope
  end

  def build_query_string(params = {})
    query_str = params[:query]
    query_str = "%#{query_str}" if ['contains', 'ends_with'].include?(params[:query_type].to_s)
    query_str = "#{query_str}%" if ['contains', 'begins_with'].include?(params[:query_type].to_s)
    # Note that 'contains' will add an '%' to the beginning AND to the end

    query_str
  end
end
