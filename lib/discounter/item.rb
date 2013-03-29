module Discounter
  class Item
    attr_accessor :code, :name, :price

    def initialize(code, name, price)
      @code = code
      @name = name
      @price = price
    end
  end
end
