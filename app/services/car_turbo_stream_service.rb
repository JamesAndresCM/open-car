class CarTurboStreamService
  def initialize(view_context)
    @view_context = view_context
  end

  def render_form_modal(car, brands)
    form_content = @view_context.render(
      partial: "cars/form",
      formats: [ :html ],
      locals: { car: car, brands: brands }
    )

    @view_context.turbo_stream.replace(
      "remote_modal",
      partial: "shared/form_modal",
      locals: { content: form_content }
    )
  end

  def handle_form_errors(car, brands)
    [
      @view_context.turbo_stream.replace("car_form", partial: "cars/form", locals: { car: car, brands: brands }),
      @view_context.turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
    ]
  end

  def handle_successful_create(cars, pagy, total_count, brands)
    [
      @view_context.turbo_stream.replace("cars_results", partial: "cars/cars_list", locals: { cars: cars, pagy: pagy }),
      @view_context.turbo_stream.replace("results_count", partial: "shared/results_count", locals: { count: total_count }),
      @view_context.turbo_stream.replace("car_form", partial: "cars/form", locals: { car: CarDecorator.new(Car.new), brands: brands }),
      @view_context.turbo_stream.update(:remote_modal, ""),
      @view_context.turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
    ]
  end

  def handle_successful_update(car)
    [
      @view_context.turbo_stream.replace("car_#{car.id}", partial: "cars/car", locals: { car: car }),
      @view_context.turbo_stream.update(:remote_modal, ""),
      @view_context.turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
    ]
  end

  def handle_successful_destroy(car)
    [
      @view_context.turbo_stream.remove("car_#{car.id}"),
      @view_context.turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
    ]
  end

  def handle_index_filter(cars, pagy, total_count)
    [
      @view_context.turbo_stream.replace("cars_results", partial: "cars/cars_list", locals: { cars: cars, pagy: pagy }),
      @view_context.turbo_stream.replace("results_count", partial: "shared/results_count", locals: { count: total_count })
    ]
  end
end
