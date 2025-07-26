class CarsController < ApplicationController
  before_action :set_car, only: %i[ show edit update destroy ]
  before_action :load_brands, only: %i[ index new edit create update ]

  # GET /cars or /cars.json
  def index
    @car_filter = CarFilter.new(filter_params)
    filtered_cars = @car_filter.filter
    @total_count = filtered_cars.count # Obtener el total antes de la paginación
    @pagy, @cars = pagy(filtered_cars)
    puts "🔄 Sending Turbo Stream response with #{@total_count} total cars, #{@cars.count} on this page"

    respond_to do |format|
      format.html # Para la carga inicial, @total_count ya está disponible
      format.turbo_stream do
        Rails.logger.info "🔄 Sending Turbo Stream response:"
        Rails.logger.info "  - Total cars found: #{@total_count}"
        Rails.logger.info "  - Cars on this page: #{@cars.count}"

        render turbo_stream: [
          turbo_stream.replace("cars_results", partial: "cars/cars_list", locals: { cars: @cars, pagy: @pagy }),
          turbo_stream.replace("results_count", partial: "shared/results_count", locals: { count: @total_count })
        ]
      end
    end
  end
  def show
  end

  # GET /cars/new
  def new
    @car = Car.new

    respond_to do |format|
      format.turbo_stream do
        form_content = render_to_string(
          partial: "cars/form",
          formats: [ :html ], # 👈 IMPORTANTE
          locals: { car: @car, brands: @brands }
        )

        render turbo_stream: turbo_stream.replace(
          "remote_modal",
          partial: "shared/form_modal",
          locals: { content: form_content }
        )
      end

      format.html { head :ok }
    end
  end

  # GET /cars/1/edit
  def edit
    respond_to do |format|
      format.turbo_stream do
        form_content = render_to_string(
          partial: "cars/form",
          formats: [ :html ],
          locals: { car: @car, brands: @brands }
        )

        render turbo_stream: turbo_stream.replace(
          "remote_modal",
          partial: "shared/form_modal",
          locals: { content: form_content }
        )
      end

      format.html { head :ok }
    end
  end


  # POST /cars or /cars.json
  def create
    @car = Car.new(car_params)

    respond_to do |format|
      if @car.save
        format.html { redirect_to @car, notice: "Auto creado exitosamente." }
        format.json { render :show, status: :created, location: @car }
        format.turbo_stream do
          flash.now[:notice] = "¡Auto creado exitosamente!"

          # Recargar toda la lista para mantener consistencia
          @car_filter = CarFilter.new({})
          filtered_cars = @car_filter.filter
          @total_count = filtered_cars.count
          @pagy, @cars = pagy(filtered_cars)

          render turbo_stream: [
            turbo_stream.replace("cars_results", partial: "cars/cars_list", locals: { cars: @cars, pagy: @pagy }),
            turbo_stream.replace("results_count", partial: "shared/results_count", locals: { count: @total_count }),
            turbo_stream.replace("car_form", partial: "form", locals: { car: Car.new }),
            turbo_stream.update(:remote_modal, ""),
            turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @car.errors, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Error al crear el auto. Revisa los campos."
          render turbo_stream: [
            turbo_stream.replace("car_form", partial: "cars/form", locals: { car: @car, brands: @brands }),
            turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
          ]
        end
      end
    end
  end

  # PATCH/PUT /cars/1 or /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        format.turbo_stream do
          flash.now[:notice] = "¡Auto actualizado exitosamente!"
          render turbo_stream: [
            # Reemplaza la card del auto actualizado en la lista
            turbo_stream.replace("car_#{@car.id}", partial: "cars/car", locals: { car: @car }),

            # Cierra el modal vaciando el contenido
            turbo_stream.update(:remote_modal, ""),

            # Muestra el mensaje flash
            turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
          ]
        end
        format.html { redirect_to @car, notice: "Auto actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @car }
      else
        format.turbo_stream do
          flash.now[:alert] = "Error al actualizar el auto. Revisa los campos."
          # Reemplaza el form en el modal con los errores para corregir
          render turbo_stream: [
            turbo_stream.replace("car_form", partial: "cars/form", locals: { car: @car, brands: @brands }),
            turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /cars/1 or /cars/1.json
  def destroy
    @car.destroy!

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Auto eliminado exitosamente."
        render turbo_stream: [
          turbo_stream.remove("car_#{@car.id}"),
          turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_car
      @car = Car.find(params.expect(:id))
    end

    # Load brands for forms and filters
    def load_brands
      @brands = Brand.all.order(:name)
    end

    # Only allow a list of trusted parameters through.
    def car_params
      params.expect(car: [ :model, :year, :transmission, :condition, :mileage, :color, :price, :image, :brand_id ])
    end

    # Parámetros permitidos para el filtro
    def filter_params
      params.fetch(:car_filter, {}).permit(
        :search, :brand_id, :transmission, :condition, :color,
        :min_year, :max_year, :min_price, :max_price, :min_mileage, :max_mileage
      )
    end
end
