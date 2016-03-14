require_relative './models/restaurant'

Geocoder.configure(units: :km)
PI = 3.14159
CENTROID_AREA_RADIUS = 1

parsed_response = Restaurant.api_request("https://api.resmio.com/v1/facility?near=\'13.383333,52.516667\'&distance=5000") # distance didn't work
restaurants_array = Restaurant.create_restaurants_array(parsed_response)

# Centroid of the restaurants around the center of Berlin
centroid = Geocoder::Calculations.geographic_center(restaurants_array.map{|r| [r.latitude, r.longitude]}) 

puts "Centroid coordinates of restaurants around the center of Berlin: #{centroid[0]}, #{centroid[1]}"

# Density of the restaurants
parsed_response_for_density = Restaurant.api_request("https://api.resmio.com/v1/facility?near=\'#{centroid[1]},#{centroid[0]}\'&distance=1000") # distance didn't work
restaurants_array_for_density = Restaurant.create_restaurants_array(parsed_response_for_density)
density = restaurants_array_for_density.count/PI*CENTROID_AREA_RADIUS**2

puts "Density of restaurants around the centroid: #{density}"

# Five closest restaurants around the centroid and their distances
distances_array = Restaurant.create_distances_array(restaurants_array, centroid)
five_closest_restaurants = Restaurant.find_five_closest_restaurants(distances_array)

puts "Distances of the five closest restaurants to the centroid: "
five_closest_restaurants.each{ |r| puts "Name: #{r[:restaurant].name}, Distance: #{r[:distance]}"}