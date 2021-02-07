class PaidChannel < ApplicationCable::Channel

  def subscribed
    stream_from "paid:#{verified_receiver.token}"
  end

end
