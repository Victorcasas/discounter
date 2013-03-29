class PercentajeDiscountRule < DiscountRule
  attr_reader :amount, :discount

  def initialize(amount, discount)
    throw "Invalid discount value. Should be between 0 and 100" unless discount > 0 && discount < 100

    @amount = amount
    @discount = discount
  end

  def execute(checkout, total)
    (total > @amount) ? total * @discount / 100.00 : 0
  end
end
