FactoryBot.define do
  factory :review do
    richness { 4 }
    sweetness { 3 }
    bitterness { 2 }
    aftertaste { 4 }
    appearance { 5 }
    score { 3.6 }
    user
    product
  end
end
