json.array!(@produces) do |produce|
  json.extract! produce, :id
  json.url produce_url(produce, format: :json)
end
