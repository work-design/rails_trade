class Promote < ApplicationRecord
  include RailsTrade::Promote
  include RailsComExt::Sequence
end unless defined? Promote
