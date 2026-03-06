module Positionable
  extend ActiveSupport::Concern

  included do
    before_create :set_initial_position
  end

  class_methods do
    def positionable(scope:)
      class_attribute :position_scope_column, default: scope
    end
  end

  def move_to_position(new_pos)
    return if new_pos == position

    transaction do
      old_pos = position
      if new_pos < old_pos
        position_siblings.where(position: new_pos...old_pos).update_all("position = position + 1")
      elsif new_pos > old_pos
        position_siblings.where(position: (old_pos + 1)..new_pos).update_all("position = position - 1")
      end
      update_column(:position, new_pos)
    end
  end

  private

  def set_initial_position
    max = self.class.where(position_scope_column => self[position_scope_column]).maximum(:position)
    self.position = (max || -1) + 1
  end

  def position_siblings
    self.class.where(position_scope_column => self[position_scope_column]).where.not(id: id)
  end
end
