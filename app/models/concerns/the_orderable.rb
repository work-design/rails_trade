module TheBuyable
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, optional: true, autosave: true
  end

  def get_buyer
    if buyer
      return buyer
    else
      build_buyer(name: self.name)
      save
    end

    buyer
  end

end
