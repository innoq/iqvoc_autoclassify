class ClassificationsController < ApplicationController

  def new
    get_document
  end

  def create
    get_document
    adding_classifications = params[:concepts].split(",") - @document.classifications.map {|c| c.concept_origin}
    concept_pref_labels = []
    Classification.transaction do
      @document.update manual_update: DateTime.now
      adding_classifications.each.with_index(@document.classifications.size + 1) do |c, r|
        concept = Iqvoc::Concept.base_class.published.find_by(origin: c)
        concept_pref_labels << concept.pref_label
        Classification.find_or_create_by(document_id: params[:id], title: concept.pref_label,  concept_origin: c, weighting: 0, rank: r)
      end
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.addition_success', concepts: concept_pref_labels.join(', '))
    redirect_to document_path(params[:id])
  end

  def destroy
    deleting_classification = Classification.find(params[:classification_id])
    classifications = Classification.where("document_id = ? AND rank > ?", params[:id], deleting_classification.rank)
    Classification.transaction do
      deleting_classification.destroy
      classifications.each do |c|
        c.update rank: c.rank - 1
      end
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.delete_success', concept: deleting_classification.concept.pref_label)
    redirect_to document_path(deleting_classification.document_id)
  end

  def promote
    promoting_classification = Classification.find(params[:classification_id])
    demoting_classification = Classification.find_by(document_id: params[:id], rank: promoting_classification.rank - 1)
    Classification.transaction do
      promoting_classification.update rank: demoting_classification.rank
      demoting_classification.update rank: demoting_classification.rank + 1
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.promote_success', concept: promoting_classification.concept.pref_label, new_rank: promoting_classification.rank, old_rank: promoting_classification.rank + 1)
    redirect_to document_path(promoting_classification.document_id)
  end

  def demote
    demoting_classification = Classification.find(params[:classification_id])
    promoting_classification = Classification.find_by(document_id: params[:id], rank: demoting_classification.rank + 1)
    Classification.transaction do
      promoting_classification.update rank: demoting_classification.rank
      demoting_classification.update rank: demoting_classification.rank + 1
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.demote_success', concept: demoting_classification.concept.pref_label, new_rank: demoting_classification.rank, old_rank: demoting_classification.rank - 1)
    redirect_to document_path(promoting_classification.document_id)
  end

  private

  def get_document
    @document = Document::Base.includes(:classifications)
                              .find_by!(id: params[:id])

    @classifications = @document.classifications
                                .reorder(:rank)
                                .page(params[:page])
  end
end
