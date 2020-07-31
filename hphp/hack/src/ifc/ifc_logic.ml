(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)

open Hh_prelude
open Ifc_utils
open Ifc_types
module IMap = Int.Map
module Mapper = Ifc_mapper

(* A note on the lattice. Policies form a lattice with the
   partial order <. This relation reads 'flows to'. Bottom,
   the least policy can flow into all other policies, so it
   is used for public data. Top, on the other hand, is used
   for private data. *)

(* A small DSL to accumulate constraints *)
module Infix = struct
  let on_lists l1 l2 ~op acc =
    List.fold_left
      (List.cartesian_product l1 l2)
      ~init:acc
      ~f:(fun acc (a, b) -> op a b acc)

  let ( < ) a b acc = Cflow (a, b) :: acc

  let ( <* ) al bl = on_lists al bl ~op:( < )

  let ( = ) a b acc = Cconj (Cflow (a, b), Cflow (b, a)) :: acc

  let ( =* ) al bl = on_lists al bl ~op:( = )

  let ( && ) c1 c2 env = c2 (c1 env)
end

(* Compute the meet of two policies, returns None if
   one of the two policies is a variable. *)
let policy_meet p1 p2 =
  match (p1, p2) with
  | (Ptop, p)
  | (p, Ptop) ->
    Some p
  | (Ppurpose n1, Ppurpose n2) ->
    if String.equal n1 n2 then
      Some p1
    else
      Some Pbot
  | (Pbot, _)
  | (_, Pbot) ->
    Some Pbot
  | _ -> None

let policy_join p1 p2 =
  match (p1, p2) with
  | (Ptop, _)
  | (_, Ptop) ->
    Some Ptop
  | (Pbot, p)
  | (p, Pbot) ->
    Some p
  | (Ppurpose n1, Ppurpose n2) ->
    if String.equal n1 n2 then
      Some p1
    else
      Some Ptop
  | _ -> None

let conjoin = function
  | [] -> Ctrue
  | f :: l -> List.fold_left ~f:(fun c f -> Cconj (f, c)) ~init:f l

(* Shift bound variables by 'delta' in a policy *)
let shift ?(delta = -1) = function
  | Pbound_var v ->
    let v = v + delta in
    assert (v >= 0);
    Pbound_var v
  | c -> c

(* Quantify variables matching a predicate in
   a constraint; when the quantification happens
   under D binders, ~depth:D should be passed *)
let quantify ~pred ~quant:q ?(depth = 0) c =
  let n = ref 0 in
  (* idx maps a free variable name to a bound
     variable index *)
  let idx =
    let m = ref SMap.empty in
    fun v ->
      match SMap.find_opt v !m with
      | Some i -> i
      | None ->
        let i = !n in
        incr n;
        m := SMap.add v i !m;
        i
  in
  (* quantifies all free variables matching the predicate
     "pred" inside a policy under d binders *)
  let quantpol d = function
    | Pfree_var (v, s) when pred (v, s) -> Pbound_var (d + idx v)
    | c -> c
  in
  (* lifts quantpol to work on constraints *)
  let rec quant d = Mapper.prop (quantpol d) quant d in
  let quant_c = quant depth c in
  if !n = 0 then
    (* no free variable matched the predicate,
       simply return the original constraint *)
    c
  else
    Cquant (q, !n, quant_c)

(* A intermediate form for constraints where conditionals
   are pushed as far outside as possible and no quantifiers
   are left; it is used internally in the simplify function
   below *)
type if_tree =
  | ITE of (policy * purpose) * if_tree * if_tree
  | FLW of (policy * policy) list

(* Slow simplification procedure for constraints.
   A correctness proof for the quantifier elimination is here:
   https://github.com/mpu/hol/blob/master/hol4/constraintScript.sml *)
let simplify c =
  let split3 l =
    (* Split a list of flow constraints as:
       - lower bounds for (Pbound_var 0)
       - upper bounds for (Pbound_var 0)
       - the rest
    *)
    List.partition3_map l ~f:(function
        | (l, Pbound_var 0) -> `Fst l
        | (Pbound_var 0, u) -> `Snd u
        | f -> `Trd f)
  in
  let elim_exists l =
    (* Eliminate (Pbound_var 0) from a list of simple flow
       constraints assuming it is existentially quantified *)
    let (lbs, ubs, oth) = split3 l in
    List.unordered_append oth (List.cartesian_product lbs ubs)
  in
  let elim_forall ~max l =
    (* Eliminate (Pbound_var 0) from a list of simple flow
       constraints assuming it is universally quantified, and
       has 'max' as upper bound *)
    let (lbs, ubs, oth) = split3 l in
    List.concat
      [
        oth;
        List.map ~f:(fun l -> (l, Pbot)) lbs;
        List.map ~f:(fun u -> (max, u)) ubs;
      ]
  in
  let dedup l =
    let cpol = compare_policy in
    let compare = Tuple2.compare ~cmp1:cpol ~cmp2:cpol in
    List.filter
      ~f:(fun (p1, p2) -> not (equal_policy p1 p2))
      (List.dedup_and_sort ~compare l)
  in
  let rec pop = function
    (* Shift all the indices of bound variables by one down;
       this will crash if (Pbound_var 0) appears in the
       constraint *)
    | FLW l ->
      let f (a, b) = (shift a, shift b) in
      FLW (List.map ~f l)
    | ITE ((p, x), t1, t2) -> ITE ((shift p, x), pop t1, pop t2)
  in
  let rec elim_exists_ift = function
    (* Same as exelim above, but for if_tree constraints *)
    | FLW l -> FLW (dedup (elim_exists l))
    | ITE (c, t1, t2) ->
      assert (not (equal_policy (fst c) (Pbound_var 0)));
      ITE (c, elim_exists_ift t1, elim_exists_ift t2)
  in
  let rec cat t1 t2 =
    (* Conjoin two if_tree constraints *)
    match (t1, t2) with
    | (FLW l1, FLW l2) -> FLW (dedup (l1 @ l2))
    | (t, ITE (c, t1, t2))
    | (ITE (c, t1, t2), t) ->
      ITE (c, cat t t1, cat t t2)
  in
  let rec elim_forall_ift max = function
    (* Same as alelim above, but for if_tree constraints *)
    | FLW l -> FLW (elim_forall ~max l)
    | ITE ((Pbound_var 0, x), t1, t2) ->
      let max_if = Option.value_exn (policy_meet max (Ppurpose x)) in
      cat (elim_forall_ift max_if t1) (elim_forall_ift max t2)
    | ITE (c, t1, t2) -> ITE (c, elim_forall_ift max t1, elim_forall_ift max t2)
  in
  let rec qelim c =
    (* Stitching all of the above together lets us
       eliminate all quantifiers from a constraint *)
    match c with
    | Cquant (q, n, c) ->
      let elim =
        match q with
        | Qexists -> elim_exists_ift
        | Qforall -> elim_forall_ift Ptop
      in
      let elim l = pop (elim l) in
      funpow n ~f:elim ~init:(qelim c)
    | Ccond (c, ct, ce) -> ITE (c, qelim ct, qelim ce)
    | Cflow (p1, p2) -> FLW [(p1, p2)]
    | Cconj (cl, cr) -> cat (qelim cl) (qelim cr)
    | Ctrue -> FLW []
    | Chole _ -> invalid_arg "cannot simplify constraint with hole"
  in
  let rec import = function
    (* Convert an if_tree constraint into a regular constraint *)
    | FLW l -> conjoin (List.map ~f:(fun f -> Cflow f) l)
    | ITE (c, t1, t2) -> Ccond (c, import t1, import t2)
  in
  import (qelim c)

(* Entailment procedure for props. This function decides C1 |= C2 where C1 is
 * the transitive closure of flows and C2 is some prop where all holes are
 * closed and all quantifiers are eliminated (via simplify). This function
 * returns all flows that do not follow from the input lattice.
 *)
let rec entailment_violations lattice = function
  | Ctrue -> []
  | Ccond ((p1, p2), c1, c2) ->
    let flow = (p1, Ppurpose p2) in
    if List.is_empty @@ entailment_violations lattice (Cflow flow) then
      entailment_violations lattice c1
    else
      entailment_violations lattice c2
  | Cconj (c1, c2) ->
    entailment_violations lattice c1 @ entailment_violations lattice c2
  | Cflow (_, Ptop)
  | Cflow (Pbot, _) ->
    []
  | Cflow (p1, p2) when equal_policy p1 p2 -> []
  | Cflow flow ->
    if FlowSet.mem flow lattice then
      []
    else
      [flow]
  (* Quantifiers and Holes should have been eliminated before this point *)
  | Cquant _ -> failwith "Cquant"
  | Chole _ -> failwith "Chole"
