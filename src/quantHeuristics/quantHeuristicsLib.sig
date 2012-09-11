signature quantHeuristicsLib =
sig
 include Abbrev

  type quant_param = quantHeuristicsLibBase.quant_param
  type quant_heuristic = quantHeuristicsLibBase.quant_heuristic

  (************************************)
  (* Interface                        *)
  (************************************)

  (* Simplifier Interface *)
  val QUANT_INST_ss      : quant_param list -> simpLib.ssfrag;
  val FAST_QUANT_INST_ss : quant_param list -> simpLib.ssfrag;

  (* Tactics *)
  val QUANT_INSTANTIATE_TAC          : quant_param list -> tactic;
  val ASM_QUANT_INSTANTIATE_TAC      : quant_param list -> tactic;
  val FAST_QUANT_INSTANTIATE_TAC     : quant_param list -> tactic;
  val ASM_FAST_QUANT_INSTANTIATE_TAC : quant_param list -> tactic;

  (* Conversions *)
  val QUANT_INSTANTIATE_CONV      : quant_param list -> conv;
  val NORE_QUANT_INSTANTIATE_CONV : quant_param list -> conv;
  val FAST_QUANT_INSTANTIATE_CONV : quant_param list -> conv;

  (* Conversions that do a case split in order to instantiate quantifiers,
     if no equivalence can be proved. Be careful, this will blow up the term size! *)
  val EXPAND_QUANT_INSTANTIATE_CONV     : quant_param list -> conv;
  val NORE_EXPAND_QUANT_INSTANTIATE_CONV: quant_param list -> conv;
  val FAST_EXPAND_QUANT_INSTANTIATE_CONV: quant_param list -> conv;

  (* Consequence Conversions *)
  val QUANT_INSTANTIATE_CONSEQ_CONV      : quant_param list -> ConseqConv.directed_conseq_conv;
  val NORE_QUANT_INSTANTIATE_CONSEQ_CONV : quant_param list -> ConseqConv.directed_conseq_conv;
  val FAST_QUANT_INSTANTIATE_CONSEQ_CONV : quant_param list -> ConseqConv.directed_conseq_conv;

  (* Tactic for instantiating quantifiers manually *)
  val QUANT_TAC  : (string * Parse.term Lib.frag list * Parse.term Parse.frag list list) list -> tactic;

  (* Conversion for instantiation quantifiers manually. In order to prove equality, simple proofs are
     tried using REWRITE_CONV followed by METIS. This may easily fail. *)
  val INST_QUANT_CONV  : (string * Parse.term Lib.frag list * Parse.term Parse.frag list list) list -> conv;

  (* Debug Traces:

     QUANT_INSTANTIATE_HEURISTIC
       0 - no debug
       1 - simple traces
       2 - full traces with theorems

     QUANT_INSTANTIATE_HEURISTIC___print_term_length 
       maximal length of term strings in debug (default 20)
   *)


  (************************************)
  (* quantifier heurostic parameters  *)
  (************************************)
  
  (* stateful ones *)
  val stateful_qp        : quantHeuristicsLibBase.quant_param;
  val pure_stateful_qp   : quantHeuristicsLibBase.quant_param;
  val TypeBase_qp        : quantHeuristicsLibBase.quant_param;

  val clear_stateful_qp : unit -> unit;
  val stateful_qp___add_combine_arguments :
     quantHeuristicsLibBase.quant_param list -> unit;

  val context_qp        : quantHeuristicsLibBase.quant_param;

  (*pair type*)
  val split_pair___PABS___pred    : Abbrev.term -> Abbrev.term -> Abbrev.term option
  val split_pair___FST_SND___pred : bool -> Abbrev.term -> Abbrev.term -> Abbrev.term option
  val split_pair___ALL___pred     : Abbrev.term -> Abbrev.term -> Abbrev.term option

  val pair_qp           : (Abbrev.term -> Abbrev.term -> Abbrev.term option) list ->
                           quantHeuristicsLibBase.quant_param;
  val pair_default_qp   : quantHeuristicsLibBase.quant_param;

  (*record type*)
  val record_qp         : bool -> (Abbrev.term -> Abbrev.term -> bool) ->
                          quantHeuristicsLibBase.quant_param;
  val record_default_qp : quantHeuristicsLibBase.quant_param;

  (*other types*)
  val num_qp            : quantHeuristicsLibBase.quant_param;
  val option_qp         : quantHeuristicsLibBase.quant_param;
  val list_qp           : quantHeuristicsLibBase.quant_param;
  val sum_qp            : quantHeuristicsLibBase.quant_param;


  (* combination of all except the stateful ones *)
  val std_qp  : quantHeuristicsLibBase.quant_param;

  
  (* writing own parameters *)

  val empty_qp    : quant_param;
  val combine_qp  : quant_param -> quant_param -> quant_param;
  val combine_qps : quant_param list -> quant_param;
  val get_qp___for_types : hol_type list -> quant_param

  val distinct_qp      : thm list -> quant_param
  val rewrite_qp       : thm list -> quant_param
  val final_rewrite_qp : thm list -> quant_param
  val cases_qp         : thm list -> quant_param
  val inference_qp     : thm list -> quant_param
  val convs_qp         : conv list -> quant_param
  val heuristics_qp    : quant_heuristic list -> quant_param
  val top_heuristics_qp: quant_heuristic list -> quant_param
  val context_heuristics_qp : (thm list -> quant_heuristic) list -> quant_param
  val filter_qp        : (term -> term -> bool) list -> quant_param
  val oracle_qp        : (term -> term -> (term * term list) option) -> quant_param

end
