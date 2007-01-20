open HolKernel Parse boolLib Prim_rec 
     pairTheory sumTheory optionTheory numeralTheory;


val _ = new_theory "basicSize";

val bool_size_def = new_definition
  ("bool_size_def", ``bool_size (b:bool) = 0``);

val pair_size_def = new_definition
  ("pair_size_def", ``pair_size f g (x,y) = f x + g y``);

val one_size_def = new_definition
  ("one_size_def", ``one_size (x:one) = 0``);

val sum_size_def = 
 new_recursive_definition
   {def = ``(sum_size (f:'a->num) g (INL x) = f x) /\
            (sum_size f (g:'b->num) (INR y) = g y)``,
    name="sum_size_def", 
    rec_axiom = sumTheory.sum_Axiom};

val option_size_def = 
 new_recursive_definition
   {def = ``(option_size f NONE = 0) /\
            (option_size f (SOME x) = SUC (f x))``,
    name="option_size_def", 
    rec_axiom = optionTheory.option_Axiom};

val _ =
 let open EmitML
 in emitML (!Globals.emitMLDir)
      ("basicSize",
         MLSIG "type num = numML.num" ::
         MLSIG "type 'a  option = 'a optionML.option" ::
         MLSIG "type ('a,'b) sum = ('a,'b) sumML.sum"
         :: OPEN ["num","sum","option"]
         ::
         map (DEFN o PURE_REWRITE_RULE[arithmeticTheory.NUMERAL_DEF])
             [bool_size_def,pair_size_def,
              one_size_def,sum_size_def,option_size_def])
 end;

val _ = export_theory();

