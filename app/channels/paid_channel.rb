class PaidChannel < ApplicationCable::Channel

  def subscribed
    stream_from "paid:#{verified_receiver.user_id}"
  end

end
