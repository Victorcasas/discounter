module Discounter
  class ItemDiscountRule < DiscountRule
    attr_reader :code, :limit, :discount

    def initialize(code, limit, discount)
      @code = code
      @limit = limit
      @discount = discount
    end

    def execute(checkout, total)
      items = checkout.items.select { |item| item.code == @code }

      (items.count >= @limit) ? @discount * items.count : 0
    end
  end
end
