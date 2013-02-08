signature kind_tokens = sig

  datatype 'a kind_token
      = KindIdent of string (* alphanum name of constant kind, defined *)
      | QKindIdent of string * string (* thy name * type name *)
      | KindSymbol of string (* symbolic identifier, not :: or <= or incl  (),:  *)
      | KindVar of string
      | KindArity
      | KindNumeral of string
      | KindRankCst
      | Comma
      | LParen
      | RParen
      | LBracket
      | RBracket
      | AQ of 'a
      | Error of 'a base_tokens.base_token

  val kindtok_of : 'a qbuf.qbuf -> ((unit -> unit) * 'a kind_token locn.located)

  val token_string : 'a kind_token -> string
  val dest_aq : 'a kind_token -> 'a

  val is_ident : 'a kind_token -> bool
  val is_kindsymbol : 'a kind_token -> bool
  val is_kindvar : 'a kind_token -> bool
  val is_kindaq : 'a kind_token -> bool

end