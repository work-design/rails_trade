module TheBuyable
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, optional: true, autosave: true
  end

  def init_buyer
    build_buyer(name: self.name)
  end

end
