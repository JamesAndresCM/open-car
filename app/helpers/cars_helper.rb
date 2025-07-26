module CarsHelper
  def transmission_options_for_select(selected = nil)
    options = [ [ "Todas", "" ] ]

    Car.transmissions.keys.each do |transmission|
      label = case transmission
      when "manual"
                "Manual"
      when "automatic"
                "Autom\u00E1tica"
      else
                transmission.humanize
      end
      options << [ label, transmission ]
    end

    options_for_select(options, selected)
  end

  def condition_options_for_select(selected = nil)
    options = [ [ "Todas", "" ] ]

    Car.conditions.keys.each do |condition|
      label = case condition
      when "brand_new"
                "Nuevo"
      when "used"
                "Usado"
      when "certified"
                "Certificado"
      else
                condition.humanize
      end
      options << [ label, condition ]
    end

    options_for_select(options, selected)
  end
end
