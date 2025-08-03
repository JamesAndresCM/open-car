class CarFilterService
  def initialize(filter_params = {})
    @filter_params = filter_params
  end

  def call
    car_filter = CarFilter.new(@filter_params)
    filtered_cars = car_filter.filter
    total_count = filtered_cars.count

    {
      car_filter: car_filter,
      filtered_cars: filtered_cars,
      total_count: total_count
    }
  end

  # Método simplificado que solo retorna los datos filtrados
  def self.filter_cars(filter_params = {})
    service = new(filter_params)
    service.call
  end
end
