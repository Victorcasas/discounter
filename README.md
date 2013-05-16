#Problem
Our client is an online marketplace, here is a sample of some of the products available on our site:

| Product code  | Name                   | Price |
| ------------- |:----------------------:| -----:|
| 001           | Lavender heart         |  9.25 |
| 002           | Personalised cufflinks | 45.00 |
| 003           | are neat               | 19.95 |

Our marketing team want to offer promotions as an incentive for our customers to purchase these items.

If you spend over £60, then you get 10% of your purchase
If you buy 2 or more lavender hearts then the price drops to £8.50.

Our check-out can scan items in any order, and because our promotions will change, it needs to be flexible regarding our promotional rules.

The interface to our checkout looks like this (shown in Ruby):

```ruby
  co = Checkout.new(promotional_rules)
  co.scan(item)
  co.scan(item)
  price = co.total
```

Implement a checkout system that fulfills these requirements.

##Test data
Basket: 001,002,003
Total price expected: £66.78

Basket: 001,003,001
Total price expected: £36.95

Basket: 001,002,001,003
Total price expected: £73.76

#How do I use it?

Well it's pretty simple, first things first, we need to install it. Since I didn't uploaded it in RubyGems (and probably wont do it anytime soon), you have 2 options:

* Using Bundler:
  Bundler is great handling git gems, it only takes this to install it:
```
  gem 'discounter', git: 'https://alvarola@bitbucket.org/alvarola/discounter.git'
```

* Local install:
  This version you need to clone the repo, build and install the gem:

```
  git clone https://alvarola@bitbucket.org/alvarola/discounter.git
  cd discounter
  gem build discounter.gemspec
  gem install ./discounter.X-X-X.gem
```

  NOTE: You should replace X-X-X with whatever version the ```gem build``` command reported.

```ruby
  require 'discounter'
```

Now we have available a couple classes in order to work with the checkout line:

* Item: It's basically a product, it has a code, name and price
* DiscountRules: This class contains the recepies to build discounting rules. You can select one and give them options, and in order to extend, just create a new method or extend the class.
* Checkout: The machin that handles scanning products and retrieving the total amount. It should be instanciated with the Discount Rules.

And here it's an example:

```ruby
  include Discounter
  
  promotional_rules = []
  
  discount_rules = DiscountRules.new

  # Everyday discounts that you don't wanna retype every time
  promotional_rules << discount_rules.for_item({ code: "001", limit: 2, discount: 0.75 })
  promotional_rules << discount_rules.for_percentaje({ amount: 60, discount: 10 })

  co = Checkout.new(promotional_rules)

  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("002", "Item name 2", 120.75)

  price = co.total
```

If you want to build your own discount but dont want to make it permanent, then use a custom one!

```ruby
  include Discounter
  promotional_rules = []
  
  discount_rules = DiscountRules.new

  # Everyday discounts that you don't wanna retype every time. Keep it DRY!
  promotional_rules << discount_rules.for_item({ code: "001", limit: 2, discount: 0.75 })
  promotional_rules << discount_rules.for_percentaje({ amount: 60, discount: 10 })

  # This is a custom discount.
  custom_discount_rule = ->(args) do
      (args[:checkout].items.count > 2) ? 10 : 0
  end

  promotional_rules << custom_discount_rule

  co = Checkout.new(promotional_rules)

  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("002", "Item name 2", 120.75)

  price = co.total
```

Now, how can I extend the DiscountRules? Well you have two options:

1) Adding new methods to the DiscountRules (maybe in a module?)

```ruby
  # A little monkey patching
  module Discounter
    class DiscountRules
      def extended(configuration)
        ->(args) { (configuration[:is_it_enabled]) ? 100 : 0 }
      end
    end
  end
  
  include Discounter
  
  promotional_rules = []
  
  discount_rules = DiscountRules.new
  
  # There, now you have a new rule!
  promotional_rules << discount_rules.extended({ is_it_enabled: true })

  co = Checkout.new(promotional_rules)

  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("002", "Item name 2", 120.75)

  price = co.total
```

2) Extending the DiscountRules class and let the new child class implement the protected methods (for object purist)

```ruby
  include Discounter
  
  promotional_rules = []
  
  # More monkey patching on the way
  class ExtendedDiscountRules < DiscountRules
    def extended(configuration)
      ->(args) { (configuration[:is_it_enabled]) ? 100 : 0 }
    end
  end
  
  # Now we have an instance of the new extended class
  @discount_rules = ExtendedDiscountRules.new

  # Everyday discounts that you don't wanna retype every time
  promotional_rules << @discount_rules.for_item({ code: "001", limit: 2, discount: 0.75 })
  promotional_rules << @discount_rules.for_percentaje({ amount: 60, discount: 10 })

  # Le new discount rule
  promotional_rules << @discount_rules.extended({ is_it_enabled: true })

  co = Checkout.new(promotional_rules)

  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("001", "Item name 1", 20.25)
  co.scan Item.new("002", "Item name 2", 120.75)

  price = co.total
```
