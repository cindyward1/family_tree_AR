class Person < ActiveRecord::Base
  validates :name, :presence => true

  after_save :make_marriage_reciprocal

  def spouse
    if spouse_id.nil?
      nil
    else
      Person.find(spouse_id)
    end
  end

  def children
    children_array = []
    the_child = Person.where("parent1_id = #{self.id} OR parent2_id = #{self.id}")
    if !the_child.empty?
      the_child.each do |child|
        children_array << child
      end
    end
    children_array
  end

  def parents
    parent_array = []
    if !parent1_id.nil?
      parent_array << Person.find(parent1_id)
    end
    if !parent2_id.nil?
      parent_array << Person.find(parent2_id)
    end
    parent_array
  end

  def sibling_type(another_person)
    sibling_type = "none"
    if self.parent1_id != nil && another_person.parent1_id != nil
      if self.parent1_id == another_person.parent1_id
        if self.parent2_id != nil && another_person.parent2_id != nil
          if self.parent2_id == another_person.parent2_id
            sibling_type = "full"
          else
            sibling_type = "half"
          end
        else
          sibling_type = "full" # assume missing second parent is the same for both
        end
      elsif self.parent1_id == another_person.parent2_id
        if self.parent2_id == another_person.parent1_id
          sibling_type = "full" # parent postions are reversed
        else
          sibling_type = "half"
        end
      elsif self.parent2_id == another_person.parent1_id
        sibling_type = "half"
      else
        sibling_type = "none"
      end
    else
      sibling_type = "none"
    end
    sibling_type
  end

  def ==(another_person)
    self.id == another_person.id
  end

private

  def make_marriage_reciprocal
    if spouse_id_changed?
      spouse.update(:spouse_id => id)
    end
  end
end
