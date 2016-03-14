require 'spec_helper'
require 'byebug'
require_relative '../models/restaurant'

CENTROID = [52.514659328020514, 13.390628722743601]
DISTANCE1 = 0.24884847560209225
DISTANCE2 = 0.2901764289385613
DISTANCE3 = 0.07953832617193829

R1 = "Refugium"
R2 = "Bocca di Bacco"
R3 = "Bistro am Gendarmenmarkt"
R4 = "Cookies Cream"
R5 = "La Banca"

describe Restaurant do
	it "has to create restaurants array from JSON correctly" do
		restaurants_file = File.read('spec/restaurants_json/restaurants.json')
		restaurants_hash = JSON.parse(restaurants_file)
		restaurants_array = Restaurant.create_restaurants_array(restaurants_hash)

		expect(restaurants_hash["objects"].count).to eq(restaurants_array.count)

		restaurants_hash["objects"].each do |restaurant_hash|
			restaurant_array = restaurants_array.find{|r| r.id == restaurant_hash["id"]}

			expect(restaurant_array).to_not be_nil 

			expect(restaurant_hash["name"]).to eq(restaurant_array.name)
			expect(restaurant_hash["location"][1]).to eq(restaurant_array.latitude)
			expect(restaurant_hash["location"][0]).to eq(restaurant_array.longitude)
		end
	end

	it "has to create distances array of restaurants from the centroid correctly" do
		restaurants_file = File.read('spec/restaurants_json/restaurants.json')
		restaurants_hash = JSON.parse(restaurants_file)
		restaurants_array = Restaurant.create_restaurants_array(restaurants_hash)
		distances_array = Restaurant.create_distances_array(restaurants_array, CENTROID)

		expect(distances_array[0][:distance]).to eq(DISTANCE1)
		expect(distances_array[1][:distance]).to eq(DISTANCE2)
		expect(distances_array[2][:distance]).to eq(DISTANCE3)
	end

	it "has to find the five closest restaurants of the centroid" do 
		restaurants_file = File.read('spec/restaurants_json/restaurants.json')
		restaurants_hash = JSON.parse(restaurants_file)
		restaurants_array = Restaurant.create_restaurants_array(restaurants_hash)
		distances_array = Restaurant.create_distances_array(restaurants_array, CENTROID)
		five_closest_restaurants = Restaurant.find_five_closest_restaurants(distances_array)

		expect(five_closest_restaurants[0][:restaurant].name).to eq(R1)
		expect(five_closest_restaurants[1][:restaurant].name).to eq(R2)
		expect(five_closest_restaurants[2][:restaurant].name).to eq(R3)
		expect(five_closest_restaurants[3][:restaurant].name).to eq(R4)
		expect(five_closest_restaurants[4][:restaurant].name).to eq(R5)
	end	
end 