signature type_pp =
sig

 val pp_type : type_grammar.grammar -> Portable.ppstream -> Type.hol_type -> unit
 val pp_type_with_depth :
  type_grammar.grammar -> Portable.ppstream -> int -> Type.hol_type -> unit
end
