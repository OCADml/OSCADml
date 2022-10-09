let value_map_opt ~default f = function
  | Some a -> f a
  | None   -> default
