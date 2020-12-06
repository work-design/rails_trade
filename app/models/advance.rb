class Advance < ApplicationRecord
  include RailsTrade::Good
  include RailsTrade::Advance
end unless defined? Advance
