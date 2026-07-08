module Trade
  class Item < ApplicationRecord
    include Model::Item
    include Job::Ext::Jobbed
    if defined? RailsFactory
      include Factory::Ext::ItemPurchase
      include Factory::Ext::ItemGood
    end
    if defined? RailsCrm
      include Crm::Ext::Maintainable
    end
    if defined? RailsSpace
      include Space::Ext::Item
    end
    if defined? RailsShip
      include Ship::Ext::Item
    end
    if defined? RailsNotice
      include ::Notice::Ext::Notifiable
      include ::Notice::Ext::MemberNotifiable
    end
  end
end
