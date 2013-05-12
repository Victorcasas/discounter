module Discounter
  # = A collection of discount rules
  #
  # This methods where born as a refactoring on multiple times having to write
  # them as custom discount rules
  class DiscountRules
    def simple(configuration)
      -> { Proc.new { 0 } }
    end

    def item(configuration)
      ->(args) do
        ->(args) do
          items = args[:checkout].items.select { |item| item.code == args[:configuration][:code] }
          (items.count >= args[:configuration][:limit]) ? args[:configuration][:discount] * items.count : 0
        end.call(args.merge(configuration))
      end
    end

    def percentaje(configuration)
      ->(args) do
        ->(args) do
          (args[:count] > args[:configuration][:amount]) ? args[:count] * args[:configuration][:discount] / 100.00 : 0
        end.call(args.merge(configuration))
      end
    end
  end
end
