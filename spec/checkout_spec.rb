# encoding: utf-8
require_relative "spec_helper"

include Discounter

describe "Checkout" do
  it "should require promotion rules on create" do
    proc { Checkout.new }.must_raise ArgumentError

    simple_discount_rule = ->(args) { ->() { 0 }.call(args) }

    promotion_rules = [ simple_discount_rule, simple_discount_rule]
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
    let(:discount_rules) { DiscountRules.new }
    
    let(:item_discount) do
      discount_rules.item({ configuration: { code: "001", limit: 2, discount: 0.75 } })
    end
    
    let(:percentaje_discount) do
      discount_rules.percentaje({ configuration: { amount: 60.00, discount: 10.00 } })
    end

    let(:promotional_rules) { [item_discount, percentaje_discount] }

    before do
      @checkout = Checkout.new promotional_rules
    end

    it "should make a 10% discount from total purchase if spended over 60 pounds" do
      checkout = Checkout.new([percentaje_discount])

      checkout.scan Item.new("001", "Lavender heart", 61.50)

      checkout.total.must_equal 55.35
    end

    it "should drop price by factor on multiple items" do
      checkout = Checkout.new([discount_rules.item({ configuration: { code: "001", limit: 2, discount: 0.5 } })])

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

