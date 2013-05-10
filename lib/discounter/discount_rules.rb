module Discounter
  # A collection of discount rules
  class DiscountRules
    class << self
      def select(rule, options = {})
        Proc.new do |checkout, count|
          self.send(rule).call(checkout, count, options)
        end
      end

      private

      def simple
        Proc.new { 0 }
      end

      def item
        Proc.new do |checkout, count, options|
          items = checkout.items.select { |item| item.code == options[:code] }
          (items.count >= options[:limit]) ? options[:discount] * items.count : 0
        end
      end

      def percentaje
        Proc.new { |checkout, count, options| (count > options[:amount]) ? count * options[:discount] / 100.00 : 0 }
      end
    end
  end
end

