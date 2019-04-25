module RailsTrade::PromoteGood
  extend ActiveSupport::Concern
  included do
    belongs_to :good, polymorphic: true
    belongs_to :promote
    validates :promote_id, uniqueness: { scope: [:good_type, :good_id] }
  
    enum kind: {
      only: 'only',
      except: 'except'
    }, _prefix: true
  
    after_initialize if: :new_record? do
      if promote&.overall_goods
        self.kind = 'except'
      else
        self.kind = 'only'
      end
    end
  end
  
  class_methods do
    def good_types
      RailsTrade.good_classes.map do |name|
        [PromoteGood.enum_i18n(:good_type, name), name]
      end
    end
  end
  

end
