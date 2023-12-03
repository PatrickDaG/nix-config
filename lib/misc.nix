_inputs: _self: super: let
  inherit
    (super.lib)
    unique
    foldl'
    filter
    ;

  # Counts how often each element occurrs in xs.
  # Elements must be strings.
  countOccurrences =
    foldl'
    (acc: x: acc // {${x} = (acc.${x} or 0) + 1;})
    {};
  # Returns all elements in xs that occur at least twice
  duplicates = xs: let
    occurrences = countOccurrences xs;
  in
    unique (filter (x: occurrences.${x} > 1) xs);
in {
  lib =
    super.lib
    // {
      inherit
        countOccurrences
        duplicates
        ;
    };
}
