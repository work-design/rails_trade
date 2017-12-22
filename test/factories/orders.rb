FactoryBot.define do

  factory :order do
    uuid { SecureRandom.uuid }
  end

end
