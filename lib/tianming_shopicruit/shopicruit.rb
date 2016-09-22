require 'json'
require 'net/http'

page = 1
price_sum = 0
product_types = [:clock, :watch]
loop do
  # Get a parsed JSON hash
  uri = URI("http://shopicruit.myshopify.com/products.json?page=" + page.to_s)
  res = Net::HTTP.get(uri)
  parsed = JSON.parse(res)
  products = parsed['products']

  puts "page: #{page}"  
  break if products.empty?

  products.each do |product|
    current_product_type = product['product_type']
    if product_types.include? current_product_type.downcase.to_sym
      puts "product handle: #{product['handle']}"
      variants =  product['variants']
      variants.each do |variant|
        current_price = variant['price'].to_f
        puts "current price: #{current_price}"
        price_sum += current_price
      end
    end
  end
  page += 1
end

puts price_sum
