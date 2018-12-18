FactoryBot.define do
  factory :order do
    price { 99.0 }
    quantity { 1 }
    uuid { SecureRandom.uuid }
  end

end
