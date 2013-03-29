class Checkout
  attr_reader :rules, :items

  def initialize(rules)
    @rules = rules
    @items = []
  end

  def scan(item)
    @items << item
  end

  def total
    @rules.inject(subtotal) { |count, discount_rule| count - discount_rule.execute(self, count) }.round(2)
  end

  private

  def subtotal
    items.inject(0) { |total, item| total + item.price }
  end
end
