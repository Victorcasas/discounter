require_relative "spec_helper"

describe "Checkout" do
  it "should require promotion rules on create" do
    proc { Checkout.new }.must_raise ArgumentError

    promotion_rules = [ DiscountRule.new, DiscountRule.new ]
    checkout = Checkout.new promotion_rules
  end

  describe "basic operations" do
    before do
      @checkout = Checkout.new []
    end

    it "should be able to scan items" do
      @checkout.must_respond_to "scan"

      item = Item.new("001", "Test Item", 9.25)
      @checkout.scan item

      @checkout.items.must_include item
    end

    it "it should be able to calculate total" do
      @checkout.must_respond_to "total"

      @checkout.scan Item.new("001", "Test item1", 10.00)
      @checkout.scan Item.new("002", "Test item2", 1.32)
      @checkout.scan Item.new("003", "Test item3", 17.25)

      @checkout.total.must_equal 28.57
    end
  end

  describe "promotional rules" do

    before do
      @promotional_rules = []

      @promotional_rules << ItemDiscountRule.new("001", 2, 0.75)
      @promotional_rules << PercentajeDiscountRule.new(60.00, 10.00)

      @checkout = Checkout.new @promotional_rules
    end

    it "should make a 10% discount from total purchase if spended over 60 pounds" do
      checkout = Checkout.new([ PercentajeDiscountRule.new(60.00, 10.00) ])

      checkout.scan Item.new("001", "Lavender heart", 61.50)

      checkout.total.must_equal 55.35
    end

    it "should drop price by factor on multiple items" do
      checkout = Checkout.new([ ItemDiscountRule.new("001", 2, 0.5) ])

      checkout.scan Item.new("001", "Lavender heard", 10)
      checkout.scan Item.new("001", "Lavender heard", 10)

      checkout.total.must_equal 19
    end

    it "should be valid for test case 1" do
      @checkout.scan Item.new("001", "Lavender heart", 9.25)
      @checkout.scan Item.new("002", "Personalised cufflinks", 45.00)
      @checkout.scan Item.new("003", "Kids T-shirt", 19.95)

      @checkout.total.must_equal 66.78
    end

    it "should be valid for test case 2" do
      @checkout.scan Item.new("001", "Lavender heart", 9.25)
      @checkout.scan Item.new("003", "Kids T-shirt", 19.95)
      @checkout.scan Item.new("001", "Lavender heart", 9.25)

      @checkout.total.must_equal 36.95
    end

    it "should be valid for test case 3" do
      @checkout.scan Item.new("001", "Lavender heart", 9.25)
      @checkout.scan Item.new("002", "Personalised cufflinks", 45.00)
      @checkout.scan Item.new("001", "Lavender heart", 9.25)
      @checkout.scan Item.new("003", "Kids T-shirt", 19.95)

      @checkout.total.must_equal 73.76
    end
  end
end
