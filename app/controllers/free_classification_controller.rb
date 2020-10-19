class FreeClassificationController < ApplicationController

  def index
    suggestion_params = {:languages=>['de', 'en'], :query_type=>'contains'}
    s = if params[:query] && params[:query].present?
                     Labeling::SKOSXL::Base.single_query(suggestion_params.merge(search_params).symbolize_keys)
                   else
                     []
                   end
    @suggestions = Kaminari.paginate_array(s, total_count: 15)

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
end
