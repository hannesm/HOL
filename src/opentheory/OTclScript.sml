open Opentheory OpenTheoryMap OpenTheoryCommon HolKernel boolLib bossLib
val _ = new_theory "OTcl"
val imp_def = METIS_PROVE[]``$==> = (\p q. p /\ q = p)``;
val and_def = prove(``$/\ = (\p q. (\f:bool->bool->bool. f p q) = (\f. f T T))``,
SRW_TAC [][FUN_EQ_THM,EQ_IMP_THM]);
val exists_def = prove(``$? = (λP. ∀q. (∀x. P x ⇒ q) ⇒ q)``,
SRW_TAC [][FUN_EQ_THM] THEN
SUBST_TAC [GSYM (ISPEC ``P:'a->bool`` ETA_THM)] THEN
METIS_TAC [])
val file = "cl.art"
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="confluent"},name="combinatoryLogicExample.confluent"}
val _ = OpenTheory_tyop_name{tyop={Thy="OTcl",Tyop="cl"},name="combinatoryLogicExample.cl"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="-->"},name="combinatoryLogicExample.-->"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="S"},name="combinatoryLogicExample.S"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="K"},name="combinatoryLogicExample.K"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="#"},name="combinatoryLogicExample.#"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="RTC"},name="combinatoryLogicExample.RTC"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="normform"},name="combinatoryLogicExample.normform"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="diamond"},name="combinatoryLogicExample.diamond"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="-||->"},name="combinatoryLogicExample.-||->"}

val _ = OpenTheory_const_name{const={Thy="OTcl",Name="mk_cl"},name="combinatoryLogicExample.ind_type.mk_cl"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="dest_cl"},name="combinatoryLogicExample.ind_type.dest_cl"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="cl_case"},name="combinatoryLogicExample.ind_type.cl_case"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="cl_size"},name="combinatoryLogicExample.ind_type.cl_size"}

val _ = OpenTheory_const_name{const={Thy="OTcl",Name="junk_rep"},name="combinatoryLogicExample.cl.rep"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="junk_abs"},name="combinatoryLogicExample.cl.abs"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="junk_cl0"},name="combinatoryLogicExample.ind_type.cl0"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="junk_cl1"},name="combinatoryLogicExample.ind_type.cl1"}
val _ = OpenTheory_const_name{const={Thy="OTcl",Name="junk_cl2"},name="combinatoryLogicExample.ind_type.cl2"}

(* should be in other theories *)
  val _ = OpenTheory_const_name {const={Thy="arithmetic",Name="+"},name="Number.Natural.+"}
  val _ = OpenTheory_const_name {const={Thy="arithmetic",Name="NUMERAL"},name="Unwanted.id"}
  val _ = OpenTheory_const_name {const={Thy="arithmetic",Name="BIT1"},name="Number.Numeral.bit1"}

fun ML_name "#" = "APP"
  | ML_name "-->" = "redn"
  | ML_name "-||->" = "predn"
  | ML_name s = s

val reader = {
  define_tyop=fn {name={Thy="OTcl",Tyop},ax,args,rep={Thy="OTcl",Name=rep},abs={Thy="OTcl",Name=abs}} => let
    val (P,t) = dest_comb (concl ax)
    val v     = variant (free_vars P) (mk_var ("v",type_of t))
    val th    = new_type_definition(Tyop,EXISTS(mk_exists(v,mk_comb(P,v)),t) ax)
    val bij   = define_new_type_bijections {name=Tyop^"_bij",ABS=abs,REP=rep,tyax=th}
    val [ar,ra] = CONJUNCTS bij
    val _ = Feedback.HOL_MESG("Defined tyop "^Tyop)
    in {rep_abs=SPEC_ALL ra,abs_rep=SPEC_ALL ar} end
               | _ => raise Fail "define_tyop",

  define_const=fn {Thy="OTcl",Name} => (fn rhs => new_definition ((ML_name Name)^"_def",mk_eq(mk_var(Name,type_of rhs),rhs)))
                | _ => raise Fail "define_const ",

  axiom=let
    open boolTheory
    val l = ref [imp_def,and_def,exists_def]
    fun a ths (h,c) = let
      val (th,r) = Lib.pluck (fn th => c = concl th) (!l)
      val _ = l := r
    in th end handle HOL_ERR _ =>
      fst(snd(Lib.first(fn (_,(th,_)) => aconv (concl th) c) (DB.match ["bool","ind_type","sat","combin"] c)))
    handle _ => raise Fail("axiom "^Parse.term_to_backend_string c)
  in a end
}
val thms = read_article file reader
val _ = save_thm("exports",LIST_CONJ(Net.listItems thms))
val _ = export_theory ()
