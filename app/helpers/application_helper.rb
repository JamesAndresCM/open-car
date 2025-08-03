module ApplicationHelper
  include Pagy::Frontend

  def language_options
    [
      [ "Espa\u00F1ol", "es" ],
      [ "English", "en" ]
    ]
  end

  def current_language_name
    case I18n.locale.to_s
    when "es" then "Espa\u00F1ol"
    when "en" then "English"
    else I18n.locale.to_s.titleize
    end
  end
end
