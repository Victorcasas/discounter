module Discounter
  class DiscountBuilder
    class << self
      def simple_rule()
        Proc.new do |checkout, count|
          0
        end
      end

      def item_rule(code, limit, discount)
        Proc.new do |checkout, count|
          items = checkout.items.select { |item| item.code == code }

          (items.count >= limit) ? discount * items.count : 0
        end
      end

      def percentaje_rule(amount, discount)
        Proc.new do |checkout, count|
          (count > amount) ? count * discount / 100.00 : 0
        end
      end
    end
  end
end

