(* this is an -*- sml -*- file *)
val _ = PolyML.print_depth 0;
open HolKernel Parse boolLib proofManagerLib;

val _ = let
  open PP
  fun with_pp ppfn pps x =
      Parse.respect_width_ref Globals.linewidth ppfn pps x handle e => Raise e
  fun pp_from_stringfn sf pps x = PP.add_string pps (sf x)
  fun pp2polypp (f : PP.ppstream -> 'a -> unit)
              (putString : string -> unit,
               beginBlock : int * bool -> unit,
               spaceBlock : int * int -> unit,
               endBlock : unit -> unit)
              (dpth_limit : int)
              recursive_print
              (e : 'a) =
    putString (pp_to_string (!Globals.linewidth) f e)
  fun gprint g pps t = let
    val tyg = Parse.type_grammar()
    val (_, ppt) = Parse.print_from_grammars (tyg,g)
  in
    ppt pps t
  end
  fun ppg pps g = term_grammar.prettyprint_grammar gprint pps g
  fun locpp pps l = PP.add_string pps (locn.toShortString l)
  fun tybpp pps (t:TypeBasePure.typeBase) = PP.add_string pps "<typeBase>"
  open PolyML
  val version_string_w1 =
      hd (String.tokens Char.isSpace Compiler.compilerVersion)
      handle Empty => ""
  val compiler_number =
      Real.floor (100.0 * valOf (Real.fromString version_string_w1))
      handle Option => 0
in
  if compiler_number >= 530 then
    let
      fun pp_redblackmap pps (_:('a,'b) Redblackmap.dict) =
            HOLPP.add_string pps "<Redblackmap>"
      fun pp_redblackset pps (_:'a Redblackset.set) =
            HOLPP.add_string pps "<Redblackset>"
    in
      install_pp (pp2polypp (with_pp HOLset.pp_holset));
      install_pp (pp2polypp (with_pp pp_redblackmap));
      install_pp (pp2polypp (with_pp pp_redblackset))
    end
  else ();
  install_pp (pp2polypp
                  (with_pp (Parse.term_pp_with_delimiters Hol_pp.pp_term)));
  install_pp (pp2polypp
                  (with_pp (Parse.type_pp_with_delimiters Hol_pp.pp_type)));
  install_pp (pp2polypp (with_pp Pretype.pp_pretype));
  install_pp (pp2polypp (with_pp Hol_pp.pp_thm));
  install_pp (pp2polypp (with_pp Hol_pp.pp_theory));
  install_pp (pp2polypp (with_pp type_grammar.prettyprint_grammar));
  install_pp (pp2polypp (with_pp ppg));

  install_pp (pp2polypp (with_pp proofManagerLib.pp_proof));
  install_pp (pp2polypp (with_pp proofManagerLib.pp_proofs));
  install_pp (pp2polypp (with_pp Rewrite.pp_rewrites));
  install_pp (pp2polypp (with_pp TypeBasePure.pp_tyinfo));
  install_pp (pp2polypp (with_pp DefnBase.pp_defn));
  install_pp (pp2polypp (with_pp Arbnum.pp_num));
  install_pp (pp2polypp (with_pp Arbint.pp_int));
  install_pp (pp2polypp (with_pp Arbrat.pp_rat));
  install_pp (pp2polypp (with_pp locpp));
  install_pp (pp2polypp (with_pp tybpp))
end

(*---------------------------------------------------------------------------*
 * Set up the help paths.                                                    *
 *---------------------------------------------------------------------------*)

val _ = let
fun huse s = use (Path.concat(HOLDIR, s));
in
huse "help/src-sml/Database.sig";
huse "help/src-sml/Database.sml";
huse "tools-poly/poly/Help.sig";
huse "tools-poly/poly/Help.sml"
end;
local
  open Path
  fun HELP s = toString(fromString(concat(HOLDIR, concat("help",s))))
  val SIGOBJ = toString(fromString(concat(HOLDIR, "sigobj")))
in
  val () = Help.indexfiles := HELP "HOL.Help" :: !Help.indexfiles
  val () = Help.helpdirs   := HOLDIR :: SIGOBJ :: !Help.helpdirs
  val () = Help.specialfiles :=
             {file = "help/Docfiles/HOL.help",
              term = "hol", title = "HOL Overview"}
             :: !Help.specialfiles
  val help = Help.help
end (* local *)


(*---------------------------------------------------------------------------*
 *  Set parameters for parsing and help.                                     *
 *---------------------------------------------------------------------------*)

val _ = Help.displayLines := 60;


local
 fun try_remove f = ((OS.FileSys.remove f) handle OS.SysErr _ => ());
 fun has_dq file =
      let
        val istrm = TextIO.openIn file
        fun loop() =
            case TextIO.input1 istrm of
              NONE => false
            | SOME #"`" => true
            | SOME _ => loop()
      in
        loop() before TextIO.closeIn istrm
      end handle IO.Io _ => false;
  infix ++;
  fun p1 ++ p2 = OS.Path.concat (p1, p2);
  open Systeml;
  fun unquote_to file1 file2 =
      systeml [HOLDIR ++ "bin" ++ "unquote", file1, file2];
in
fun use s =
  if has_dq s then
    let
      val filename = OS.FileSys.tmpName()
    in
      (if OS.Process.isSuccess (unquote_to s filename) then
         (PolyML.use filename; OS.FileSys.remove filename)
       else (TextIO.output(TextIO.stdOut,
                           ("Failed to translate file: "^s^"\n"));
             raise Fail "use"))
      handle e => (try_remove filename; raise e)
    end
  else PolyML.use s;
end (* local *)

val _ = Globals.interactive := true;
val _ = Parse.current_backend := Parse.interactive_ppbackend()

val build_stamp =
 let open TextIO Path;
     val stampstr = openIn (concat(HOLDIR, concat("tools", "build-stamp")));
     val stamp = inputAll stampstr before closeIn stampstr;
 in
     stamp
 end handle _ => "";

val exit_string =
    if Systeml.OS = "winNT" then
      "To exit type <Control>-Z <Return>  (*not* quit();)"
    else
      "To exit type <Control>-D"

val _ =
TextIO.output(TextIO.stdOut,
   "\n---------------------------------------------------------------------\n"
  ^"       HOL-4 ["
  ^Globals.release^" "^Lib.int_to_string(Globals.version)
  ^" ("^Thm.kernelid^", "^build_stamp^")"
  ^"]\n\n"
  ^"       For introductory HOL help, type: help \"hol\";\n"
  ^"       "^exit_string
  ^"\n---------------------------------------------------------------------\n\
   \\n")

val _ = let
  infix ++
  fun p1 ++ p2 = OS.Path.concat (p1,p2)
  fun appthis s = let
    val nm = HOLDIR ++ "tools" ++ "Holmake" ++ s
  in
    use (nm ^ ".sig");
    use (nm ^ ".sml")
  end
in
  app appthis ["regexpMatch", "parse_glob", "internal_functions",
               "Holmake_types", "ReadHMF"]
end;

use (OS.Path.concat (HOLDIR, OS.Path.concat("tools", "makefile-includes.ML")));

val _ =
  (term_pp_prefix := "``";   term_pp_suffix := "``";
   type_pp_prefix  := "``";   type_pp_suffix := "``");
structure HOL_Interactive :> sig
  val toggle_quietdec : unit -> bool
  val amquiet : unit -> bool
end =
struct
  val qd = ref false
  fun toggle_quietdec () =
      if !qd then (PolyML.Compiler.prompt1 := "> ";
                   PolyML.Compiler.prompt2 := "# ";
                   PolyML.print_depth 100;
                   qd := false;
                   false)
      else (PolyML.Compiler.prompt1 := "";
            PolyML.Compiler.prompt2 := "";
            PolyML.print_depth 0;
            qd := true;
            true)
  fun amquiet () = !qd
end;

val _ = app Meta.fakeload ["PP", "PolyML"];

use (Path.concat(Globals.HOLDIR, "tools/check-intconfig.sml"));

val _ = set_trace "pp_annotations" 1

val _ = PolyML.print_depth 100;
