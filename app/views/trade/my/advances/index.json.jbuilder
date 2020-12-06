json.advances @advances do |advance|
  json.extract! advance,
                :id,
                :name,
                :description,
                :price,
                :final_price,
                :apple_product_id,
                :amount
  json.promote_names advance.overall_promotes.pluck(:name)
end
