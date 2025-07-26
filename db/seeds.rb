# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Crear marcas de autos populares
popular_brands = [
  "Toyota",
  "Honda",
  "Ford",
  "Chevrolet",
  "Nissan",
  "Hyundai",
  "Kia",
  "Volkswagen",
  "BMW",
  "Mercedes-Benz",
  "Audi",
  "Mazda",
  "Subaru",
  "Jeep",
  "Ram",
  "GMC",
  "Cadillac",
  "Lexus",
  "Acura",
  "Infiniti",
  "Volvo",
  "Jaguar",
  "Land Rover",
  "Porsche",
  "Tesla",
  "Mitsubishi",
  "Suzuki",
  "Isuzu",
  "Peugeot",
  "Renault"
]

puts "Creando marcas de autos..."

popular_brands.each do |brand_name|
  brand = Brand.find_or_create_by!(name: brand_name)
  puts "✅ Marca creada/encontrada: #{brand.name}"
end

puts "🎉 #{Brand.count} marcas en total en la base de datos"
