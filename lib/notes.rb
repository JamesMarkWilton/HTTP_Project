def find_notes(notes, selectors)

 dict = {
   "plus" => "add",
   "+" => "add",
   "sum" => "add",
   "minus" => "subtract",
   "-" => "subtract",
   "difference" => "subtract",
   "subtraction" => "subtract",
   "division" => "divide",
   "quotient" => "divide",
   "/" => "divide",
   "%" => "divide",
   "multiplication" => "multiply",
   "*" => "multiply",
   "x" => "multiply",
   "list" => "array",
   "[]" => "array",
   "decimal" => "float",
   "decimals" => "float",
   }

  selected = notes

  selectors.each do |filter|
    if dict.has_key?(filter)
      filter = dict[filter]
    end

    final_filtered = []
    selected.each do |note|
      if note["description"][/.*#{filter}.*/i] || note["example"][/.*#{filter}.*/i]
        final_filtered << note
      end
    end
    selected = final_filtered.compact
  end

  selected.compact
end

