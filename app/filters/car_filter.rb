class CarFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Atributos de búsqueda
  attribute :search, :string
  attribute :brand_id, :integer
  attribute :transmission, :string
  attribute :condition, :string
  attribute :min_year, :integer
  attribute :max_year, :integer
  attribute :min_price, :decimal
  attribute :max_price, :decimal
  attribute :min_mileage, :integer
  attribute :max_mileage, :integer
  attribute :color, :string

  def initialize(params = {})
    super(params)
  end

  def filter(cars = Car.all)
    cars = cars.includes(:brand).with_attached_image # Optimizar consultas y precargar imágenes

    cars = filter_by_search(cars)
    cars = filter_by_brand(cars)
    cars = filter_by_transmission(cars)
    cars = filter_by_condition(cars)
    cars = filter_by_year_range(cars)
    cars = filter_by_price_range(cars)
    cars = filter_by_mileage_range(cars)
    cars = filter_by_color(cars)

    cars.order(created_at: :desc)
  end

  def has_filters?
    search.present? || brand_id.present? || transmission.present? ||
    condition.present? || min_year.present? || max_year.present? ||
    min_price.present? || max_price.present? || min_mileage.present? ||
    max_mileage.present? || color.present?
  end

  def clear_filters
    self.search = nil
    self.brand_id = nil
    self.transmission = nil
    self.condition = nil
    self.min_year = nil
    self.max_year = nil
    self.min_price = nil
    self.max_price = nil
    self.min_mileage = nil
    self.max_mileage = nil
    self.color = nil
  end

  private

  def filter_by_search(cars)
    return cars if search.blank?

    cars.joins(:brand).where(
      "cars.model ILIKE ? OR brands.name ILIKE ?",
      "%#{search}%", "%#{search}%"
    )
  end

  def filter_by_brand(cars)
    return cars if brand_id.blank?
    cars.where(brand_id: brand_id)
  end

  def filter_by_transmission(cars)
    return cars if transmission.blank?
    cars.where(transmission: transmission)
  end

  def filter_by_condition(cars)
    return cars if condition.blank?
    cars.where(condition: condition)
  end

  def filter_by_year_range(cars)
    cars = cars.where("year >= ?", min_year) if min_year.present?
    cars = cars.where("year <= ?", max_year) if max_year.present?
    cars
  end

  def filter_by_price_range(cars)
    cars = cars.where("price >= ?", min_price) if min_price.present?
    cars = cars.where("price <= ?", max_price) if max_price.present?
    cars
  end

  def filter_by_mileage_range(cars)
    cars = cars.where("mileage >= ?", min_mileage) if min_mileage.present?
    cars = cars.where("mileage <= ?", max_mileage) if max_mileage.present?
    cars
  end

  def filter_by_color(cars)
    return cars if color.blank?
    cars.where("color ILIKE ?", "%#{color}%")
  end
end
