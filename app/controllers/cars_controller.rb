# frozen_string_literal: true

class CarsController < ApplicationController
  before_action :set_car, only: %i[show edit update destroy]
  before_action :load_brands, only: %i[index new edit create update]
  before_action :setup_turbo_stream_service, only: %i[index new edit create update destroy]

  # GET /cars or /cars.json
  def index
    result = CarFilterService.filter_cars(filter_params)
    @car_filter = result[:car_filter]
    @total_count = result[:total_count]
    @pagy, cars = pagy(result[:filtered_cars])
    @cars = cars.map { |car| CarDecorator.new(car) }

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: @turbo_stream_service.handle_index_filter(@cars, @pagy, @total_count)
      end
    end
  end

  def show
    @car = CarDecorator.new(@car)
  end

  # GET /cars/new
  def new
    @car = CarDecorator.new(Car.new)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: @turbo_stream_service.render_form_modal(@car, @brands)
      end
      format.html { head :ok }
    end
  end

  # GET /cars/1/edit
  def edit
    @car = CarDecorator.new(@car)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: @turbo_stream_service.render_form_modal(@car, @brands)
      end
      format.html { head :ok }
    end
  end


  # POST /cars or /cars.json
  def create
    @car = Car.new(car_params)

    respond_to do |format|
      if @car.save
        format.turbo_stream do
          # Recargar la lista completa después de crear
          result = CarFilterService.filter_cars({})
          pagy, cars = pagy(result[:filtered_cars])
          decorated_cars = cars.map { |car| CarDecorator.new(car) }

          flash.now[:notice] = I18n.t("cars.created_successfully")
          render turbo_stream: @turbo_stream_service.handle_successful_create(
            decorated_cars,
            pagy,
            result[:total_count],
            @brands
          )
        end
      else
        format.html { redirect_to cars_path, alert: I18n.t("cars.creation_error") }
        format.turbo_stream do
          flash.now[:alert] = I18n.t("cars.creation_error")
          render turbo_stream: @turbo_stream_service.handle_form_errors(
            CarDecorator.new(@car),
            @brands
          )
        end
      end
    end
  end  # PATCH/PUT /cars/1 or /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        format.turbo_stream do
          flash.now[:notice] = I18n.t("cars.updated_successfully")
          render turbo_stream: @turbo_stream_service.handle_successful_update(CarDecorator.new(@car))
        end
        format.html { redirect_to @car, notice: I18n.t("cars.updated_successfully") }
      else
        format.turbo_stream do
          flash.now[:alert] = I18n.t("cars.update_error")
          render turbo_stream: @turbo_stream_service.handle_form_errors(
            CarDecorator.new(@car),
            @brands
          )
        end
        format.html { redirect_to @car, alert: I18n.t("cars.update_error") }
      end
    end
  end

  # DELETE /cars/1 or /cars/1.json
  def destroy
    @car.destroy!

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = I18n.t("cars.deleted_successfully")
        render turbo_stream: @turbo_stream_service.handle_successful_destroy(@car)
      end
    end
  end

  private

  def set_car
    @car = Car.find(params.expect(:id))
  end

  def load_brands
    @brands = Brand.all.order(:name)
  end

  def setup_turbo_stream_service
    @turbo_stream_service = CarTurboStreamService.new(view_context)
  end

  def car_params
    params.expect(car: %i[model year transmission condition mileage color price image brand_id])
  end

  def filter_params
    params.fetch(:car_filter, {}).permit(
      :search, :brand_id, :transmission, :condition, :color,
      :min_year, :max_year, :min_price, :max_price, :min_mileage, :max_mileage
    )
  end
end
