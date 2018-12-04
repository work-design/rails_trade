require 'httparty'
module ApplePay
  URL = 'https://buy.itunes.apple.com/verifyReceipt'
  SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt'
  extend self

  def verify(receipt_data, sandbox = false)
    if sandbox
      url = SANDBOX_URL
    else
      url = URL
    end

    options = {
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      body: { 'receipt-data' => receipt_data }
    }

    r = HTTParty.post(url, options)

    binding.pry

    resp_body = resp
    json_resp = JSON.parse(resp_body.body)
  end

end
