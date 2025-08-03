# frozen_string_literal: true

class CarDecorator < SimpleDelegator
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::NumberHelper
  extend ActionView::Helpers::FormOptionsHelper

  def self.transmission_options_for_select(selected = nil)
    options = [ [ I18n.t("transmission.all"), "" ] ]

    Car.transmissions.keys.each do |transmission|
      label = I18n.t("transmission.#{transmission}")
      options << [ label, transmission ]
    end

    options_for_select(options, selected)
  end

  def self.condition_options_for_select(selected = nil)
    options = [ [ I18n.t("condition.all"), "" ] ]

    Car.conditions.keys.each do |condition|
      label = I18n.t("condition.#{condition}")
      options << [ label, condition ]
    end

    options_for_select(options, selected)
  end

  def self.transmission_options_for_form(selected = nil)
    options = []

    Car.transmissions.keys.each do |transmission|
      label = I18n.t("transmission.#{transmission}")
      options << [ label, transmission ]
    end

    options_for_select(options, selected)
  end

  def self.condition_options_for_form(selected = nil)
    options = []

    Car.conditions.keys.each do |condition|
      label = I18n.t("condition.#{condition}")
      options << [ label, condition ]
    end

    options_for_select(options, selected)
  end

  # Métodos de instancia para el car decorado
  def formatted_transmission
    I18n.t("transmission.#{transmission}")
  end

  def formatted_condition
    I18n.t("condition.#{condition}")
  end

  def formatted_price
    number_to_currency(price, unit: "$", separator: ".", delimiter: ",")
  end

  def formatted_mileage
    return "0 km" if mileage.to_i.zero?

    number_with_delimiter(mileage) + " km"
  end
end
