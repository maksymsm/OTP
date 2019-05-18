require "./LexicalAnalyzer/lexer"

class CodeGenerator
    def initialize(tree)
        @tree = tree
    end

    def generate
        @registers = ["eax", "ebx", "ecx", "edx", "edi", "esi"]
        @reg_index = 0
        @all_proc = []
        current_element = @tree.root.leaves[0]

        file = File.open('rezult.txt', 'w')
        file.puts semantic_function(current_element.val, current_element.leaves)
        file.close
    end

    def semantic_function(elem, list)
        case elem
        when "<signal-program>"
            ".model small\n.stack 100h\n.data\n" + data_declaration() + "\n.code\n\n" + \
            semantic_function(list[0].val, list[0].leaves)
        when "<program>"
             func_name = semantic_function(list[1].val, list[1].leaves)
             @main_proc = func_name
             semantic_function(list[4].leaves[0].val, list[4].leaves[0].leaves) + "\n" + func_name + " proc\n" + \
                semantic_function(list[4].val, list[4].leaves) + func_name + " endp\n" + "end " + func_name + "\n"
        when "<block>"
            semantic_function(list[2].val, list[2].leaves)
        when "<declarations>"
            semantic_function(list[0].val, list[0].leaves)
        when "<procedure-declarations>"
            if list.length < 2
                return ''
            end
            semantic_function(list[1].val, list[1].leaves) + semantic_function(list[2].val, list[2].leaves)
        when "<procedure>"
            func_name = semantic_function(list[1].val, list[1].leaves)
            if func_name != @main_proc
                @all_proc.push(func_name)
            else
                $error.push("Code generator error: you can't use the main procedure")
                return "\n  Code generator error: you can't use the main procedure\n"
            end
            func_name + " proc\n" + semantic_function(list[2].val, list[2].leaves) + func_name + " endp\n"
        when "<parameters-list>"
            @all_proc.push(0)
            if list.length < 2
                return "  ;some action\n"
            end
            str = "  push ebp\n  mov ebp, esp\n" + pop_elem_from_stack(semantic_function(list[1].val, list[1].leaves)) \
                 + semantic_function(list[2].val, list[2].leaves) + "  ; some action\n  pop ebp\n  ret #{@reg_index * 4}\n"
            @reg_index = 0
            str
        when "<identifiers-list>"
            if list.length < 2
                return ''
            end
            pop_elem_from_stack(semantic_function(list[1].val, list[1].leaves)) + semantic_function(list[2].val, list[2].leaves)
        when "<statements-list>"
            if list[0].val == "<empty-block>"
                return ''
            end
            semantic_function(list[0].val, list[0].leaves) + semantic_function(list[1].val, list[1].leaves)
        when "<statement>"
            if list[0].leaves[0].val == "<empty>"
                semantic_function(list[1].val, list[1].leaves)
            else
                func_name = semantic_function(list[0].val, list[0].leaves)
                pos = @all_proc.index(func_name)
                @param_amount = 0
                val = ""
                if !pos
                    $error.push("Code generator error: #{func_name} - unknow procedure")
                    return "\n  Code generator error: #{func_name} - unknow procedure\n"
                else
                    val = semantic_function(list[1].val, list[1].leaves) + "  call #{func_name}\n"
                end
                if @param_amount != @all_proc[pos + 1]
                    $error.push("Code generator error: To #{func_name} procedure pass #{@param_amount} param, but expected #{@all_proc[pos + 1]}")
                    return "\n  Code generator error: To #{func_name} procedure pass #{@param_amount} param, but expected #{@all_proc[pos + 1]}\n"
                end
                @param_amount = 0
                val
             end
        when "<return>"
            "  ret\n"
        when "<actual-arguments>"
            if list.length < 2
                return ''
            end
            "  push " + semantic_function(list[1].val, list[1].leaves) + "\n" + semantic_function(list[2].val, list[2].leaves)
        when "<actual-arguments-list>"
            if list.length < 2
                return ''
            end
            "  push " + semantic_function(list[1].val, list[1].leaves) + "\n" + semantic_function(list[2].val, list[2].leaves)
        when "<variable-identifier>"
            @all_proc[@all_proc.length - 1] += 1
            semantic_function(list[0].val, list[0].leaves)
        when "<procedure-identifier>"
            semantic_function(list[0].val, list[0].leaves)
        when "<identifier>"
            list[0].val
        when "<unsigned-integer>"
            @param_amount += 1
            list[0].val
        end
    end

    def data_declaration
        "//some data here"
    end

    def pop_elem_from_stack(elem)
        @reg_index += 1
        pop_elem = "  mov #{@registers[@reg_index - 1]}, [ebp + #{(@reg_index + 1)* 4}]  ; put param #{elem} to #{@registers[@reg_index]}\n"
    end
end
