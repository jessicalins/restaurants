require 'rest-client'
require 'json'
require 'geocoder'
require 'byebug'
require_relative './models/restaurant'

Geocoder.configure(units: :km)
PI = 3.14159
CENTROID_AREA_RADIUS = 1

def api_request(url)
	response = RestClient.get(url)
	parsed_response = JSON.parse(response)
	parsed_response
end

def create_restaurants_array(parsed_response)
	restaurants_array = []

	parsed_response["objects"].each do |restaurant|
		unless restaurant["name"].nil? || restaurant["location"].nil?
			restaurant = Restaurant.new(restaurant["name"], restaurant["location"][1], restaurant["location"][0]) 
			restaurants_array.push(restaurant)
		end
	end

	restaurants_array
end

def create_distances_array(restaurants_array, centroid)
	restaurants_distances = []

	restaurants_array.each do |restaurant|
		restaurant_distance_hash = {}
		distance = Geocoder::Calculations.distance_between([restaurant.latitude, restaurant.longitude], centroid)
		restaurant_distance_hash[:distance] = distance
		restaurant_distance_hash[:restaurant] = restaurant
		restaurants_distances.push(restaurant_distance_hash)
	end

	restaurants_distances
end	

def find_five_closest_restaurants(restaurants_distances)
	restaurants_distances.sort!{ |r1,r2| r1[:distance] <=> r2[:distance] }
	restaurants_distances[0..4]
end

parsed_response = api_request("https://api.resmio.com/v1/facility?near=\'13.383333,52.516667\'&distance=5000") # distance didn't work
restaurants_array = create_restaurants_array(parsed_response)

# Centroid of the restaurants around the center of Berlin
centroid = Geocoder::Calculations.geographic_center(restaurants_array.map{|r| [r.latitude, r.longitude]}) 

puts "Centroid coordinates of restaurants around the center of Berlin: #{centroid[0]}, #{centroid[1]}"

# Density of the restaurants
parsed_response_for_density = api_request("https://api.resmio.com/v1/facility?near=\'#{centroid[1]},#{centroid[0]}\'&distance=1000") # distance didn't work
restaurants_array_for_density = create_restaurants_array(parsed_response_for_density)
density = restaurants_array_for_density.count/PI*CENTROID_AREA_RADIUS**2

puts "Density of restaurants around the centroid: #{density}"

# Five closest restaurants around the centroid and their distances
distances_array = create_distances_array(restaurants_array, centroid)
five_closest_restaurants = find_five_closest_restaurants(distances_array)

puts "Distances of the five closest restaurants to the centroid: "
five_closest_restaurants.each{ |r| puts "Name: #{r[:restaurant].name}, Distance: #{r[:distance]}"}