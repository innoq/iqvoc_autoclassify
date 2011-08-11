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

end
