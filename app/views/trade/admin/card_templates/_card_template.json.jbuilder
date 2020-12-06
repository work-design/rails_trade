json.extract! card_template,
              :id,
              :name,
              :valid_days
json.advances card_template.advances do |advance|
  json.extract! advance, :amount, :price
end
