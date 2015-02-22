# include by Item Model
module ItemTaxonScope
  extend ActiveSupport::Concern

  included do

    # 根节点
    scope :roots, -> { where(node_type: node_types[:node_top]) }
  end

  def siblings_and_self
    parent_ids = self.parents.pluck(:id)
    if parent_ids.blank?
      self.class.roots
    else
      child_ids = CategoryTaxon.where("parent_id = ?", parent_ids).pluck(:child_id)
      self.class.find child_ids
    end
  end

  # 更新item的节点状态
  def update_node_type

  end


  module ClassMethods



  end

end

