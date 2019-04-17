class Node
  attr_accessor :leaves, :val, :parent_element
  def initialize(val, per_elem)
        @val = val
        @parent_element = per_elem
        @leaves = []
  end
end
