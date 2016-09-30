require 'json'
require 'net/http'

class ShopifyProduct
  def initialize(uri)
    @uri = uri
    @products = get_products
  end

  private
  # number => array of products
  # Returns an array of the products at the specified page number
  def get_products_at_page(page)
    endpoint = "?page="
    uri = URI(@uri + endpoint + page.to_s)
    res = Net::HTTP.get(uri)
    parsed = JSON.parse(res)
    products = parsed['products']
  end

  # => array of products
  # Rerturns an array of products for all pages of the uri specified during initialization
  def get_products
    products = []
    page = 1
    loop do
      current_products = get_products_at_page(page)
      break if current_products.empty?
      page += 1
      products += current_products
    end
    products
  end

  # array of variants => array of floats
  # Given an array of variants, returns an array of their respective prices
  def calc_variants_prices_sum(variants)
    variants_prices = variants.map do |variant|
      variant['price'].to_f
    end
    variants_prices.reduce(&:+)
  end

  public
  # array of symbols => float
  # Returns the sum of the prices of all product variants of the types specified in product_types
  def calc_total_price(product_types)
    products_prices = @products.map do |product|
      current_product_type = product['product_type']
      if product_types.include? current_product_type.downcase.to_sym
        variants =  product['variants']
        calc_variants_prices_sum(variants)
      else
        0
      end
    end
    products_prices.reduce(&:+).round 2
  end

  if __FILE__ == $0
    products = ShopifyProduct.new "http://shopicruit.myshopify.com/products.json"  
    product_types = [:clock, :watch]
    price = products.calc_total_price product_types
    puts "The total amount required to purchase all the clocks and watches is #{price}."
  end
end
