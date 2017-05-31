json.array!(@signs) do |sign|
  json.extract! sign, :id
  json.url sign_url(sign, format: :json)
end
