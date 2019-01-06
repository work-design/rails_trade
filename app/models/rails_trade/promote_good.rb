class PromoteGood < ApplicationRecord
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

  def self.good_types
    RailsTrade.good_classes.map do |name|
      [PromoteGood.enum_i18n(:good_type, name), name]
    end
  end

end unless RailsTrade.config.disabled_models.include?('PromoteGood')
