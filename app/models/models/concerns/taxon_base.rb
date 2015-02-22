
# 使用方法 include Helper::TaxonBase
module Helper
  module TaxonBase

    private
    def parent_id_was
      ancestry_was.last
    end

    def update_parent_counter_cache
      self.class.increment_counter(:children_count, parent_id)
    end

    def update_parents_counter_cache
      if self.ancestry_was.blank? && respond_to?(:children_count) && ancestry_changed?
        self.class.increment_counter(:children_count, parent_id)
      elsif self.respond_to?(:children_count) && ancestry_changed?
        self.class.decrement_counter(:children_count, parent_id_was)
        self.class.increment_counter(:children_count, parent_id)
      end
    end

  end
end
