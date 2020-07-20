class Promote < ApplicationRecord
  include RailsTrade::Promote
  include RailsTaxon::Sequence
end unless defined? Promote
