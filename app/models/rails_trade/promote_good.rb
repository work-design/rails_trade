class PromoteGood < ApplicationRecord

  belongs_to :good, polymorphic: true
  belongs_to :promote

  enum kind: {
    only: 'only',
    except: 'except'
  }, _prefix: true

  def self.good_types
    RailsTrade.good_classes.map do |name|
      [PromoteGood.enum_i18n(:good_type, name), name]
    end
  end

end unless RailsTrade.config.disabled_models.include?('PromoteGood')
