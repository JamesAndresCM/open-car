class Car < ApplicationRecord
  belongs_to :brand
  has_one_attached :image
  enum :transmission, { manual: 0, automatic: 1 }, prefix: true
  enum :condition, { brand_new: 0, used: 1, certified: 2 }, prefix: true
  delegate :name, to: :brand, prefix: true

  # Turbo Broadcast para actualizaciones en tiempo real
  after_update_commit :broadcast_price_update, if: :saved_change_to_price?

  private

  def broadcast_price_update
    Rails.logger.info "🔄 Broadcasting price update for Car ##{id}: $#{price}"

    broadcast_update_to(
      "cars_channel",
      target: "car_#{id}_price",
      partial: "cars/price",
      locals: { car: CarDecorator.new(self) }
    )
  end
end
