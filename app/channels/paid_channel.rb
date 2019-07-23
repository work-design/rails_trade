class PaidChannel < ApplicationCable::Channel
  
  def subscribed
    stream_from "paid:#{current_receiver.id}" if current_receiver
  end
  
end
