module Discounter
  # = A collection of discount rules
  #
  # The basic usage is: if you use a discounter more than once
  # then you should create a method, for all the rest (there's mastercard :P)
  # use custom.
  class DiscountRules
    class << self
      def select(rule, options = {}, &block)
        if block_given?
          Proc.new { |checkout, count| self.send(rule, block).call(checkout, count, options) }
        else
          Proc.new { |checkout, count| self.send(rule).call(checkout, count, options) }
        end
      end

      def custom(block)
        Proc.new do |checkout, count, options|
          block.call(checkout, count, options)
        end
      end

      protected

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

