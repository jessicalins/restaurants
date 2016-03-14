require 'rest-client'
require 'json'
require 'geocoder'

class Restaurant
	attr_accessor :id, :name, :latitude, :longitude

	def initialize(id, name, latitude, longitude)
		@id = id
		@name = name
		@latitude = latitude
		@longitude = longitude
	end

	def self.api_request(url)
		response = RestClient.get(url)
		parsed_response = JSON.parse(response)
		parsed_response
	end

	def self.create_restaurants_array(parsed_response)
		restaurants_array = []

		parsed_response["objects"].each do |restaurant|
			unless restaurant["id"].nil? || restaurant["name"].nil? || restaurant["location"].nil?
				restaurant = Restaurant.new(restaurant["id"], restaurant["name"], restaurant["location"][1], restaurant["location"][0]) 
				restaurants_array.push(restaurant)
			end
		end

		restaurants_array
	end

	def self.create_distances_array(restaurants_array, centroid)
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

	def self.find_five_closest_restaurants(restaurants_distances)
		restaurants_distances.sort!{ |r1,r2| r1[:distance] <=> r2[:distance] }
		restaurants_distances[0..4]
	end
end