class Tree
  attr_accessor :root, :current_element
  def initialize()
    @root = Node.new("signal-program", nil)
    @current_element = @root
  end

  def add(val)
        tmp_cur_elem = Node.new(val, @current_element)
        @current_element.leaves.push(tmp_cur_elem)
        @current_element = tmp_cur_elem
  end

  def print_tree()
        if @root != nil
            __print_tree(@root, 0)
        end
  end

  def __print_tree(root, depth)
        print "\n"
        for i in (0..depth).to_a
            print " "
        end
        unless root.leaves.empty?
            print '<' + root.val.to_s + '>'
        else
            print root.val.to_s
        end

        for leaf in root.leaves
            __print_tree(leaf, depth+1)
        end
  end

  def listing()
        if @root != nil
            __listing(@root)
        end
  end

  def __listing(root)
        if root.leaves.empty?
            if root.val == "empty"
                puts
                return
            end
            if root.val == ';' or root.val == '.'
                puts root.val
            else
                print root.val + " "
            end
        end
        for leaf in root.leaves
            __listing(leaf)
        end
  end

end
