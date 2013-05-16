module Discounter
  # = A collection of discount rules
  #
  # This methods where born as a refactoring on multiple times having to write
  # them as custom discount rules
  class DiscountRules
    def simple(configuration)
      -> { 0 }
    end

    def for_item(configuration)
      ->(args) do
        items = args[:checkout].items.select { |item| item.code == configuration[:code] }
        (items.count >= configuration[:limit]) ? configuration[:discount] * items.count : 0
      end
    end

    def for_percentaje(configuration)
      ->(args) do
        (args[:count] > configuration[:amount]) ? args[:count] * configuration[:discount] / 100.00 : 0
      end
    end
  end
end
