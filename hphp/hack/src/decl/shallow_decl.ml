(*
 * Copyright (c) 2018, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)

open Hh_prelude
open Decl_defs
open Shallow_decl_defs
open Aast
open Typing_deps
open Typing_defs
module Attrs = Naming_attributes
module FunUtils = Decl_fun_utils

let class_const env c cc =
  let { cc_id = name; cc_type = h; cc_expr = e; cc_doc_comment = _ } = cc in
  let pos = fst name in
  match c.c_kind with
  | Ast_defs.Ctrait -> None
  | Ast_defs.Cnormal
  | Ast_defs.Cabstract
  | Ast_defs.Cinterface
  | Ast_defs.Cenum ->
    let (ty, abstract) =
      (* Optional hint h, optional expression e *)
      match (h, e) with
      | (Some h, Some _) -> (Decl_hint.hint env h, false)
      | (Some h, None) -> (Decl_hint.hint env h, true)
      | (None, Some e) ->
        begin
          match Decl_utils.infer_const e with
          | Some tprim -> (mk (Reason.Rwitness (fst e), Tprim tprim), false)
          | None ->
            (* Typing will take care of rejecting constants that have neither
             * an initializer nor a literal initializer *)
            (mk (Reason.Rwitness pos, Typing_defs.make_tany ()), false)
        end
      | (None, None) ->
        (* Typing will take care of rejecting constants that have neither
         * an initializer nor a literal initializer *)
        let r = Reason.Rwitness pos in
        (mk (r, Typing_defs.make_tany ()), true)
    in
    Some { scc_abstract = abstract; scc_name = name; scc_type = ty }

let typeconst_abstract_kind env = function
  | Aast.TCAbstract default ->
    TCAbstract (Option.map default (Decl_hint.hint env))
  | Aast.TCPartiallyAbstract -> TCPartiallyAbstract
  | Aast.TCConcrete -> TCConcrete

let typeconst env c tc =
  match c.c_kind with
  | Ast_defs.Ctrait
  | Ast_defs.Cenum ->
    None
  | Ast_defs.Cinterface
  | Ast_defs.Cabstract
  | Ast_defs.Cnormal ->
    let as_constraint =
      Option.map tc.c_tconst_as_constraint (Decl_hint.hint env)
    in
    let ty = Option.map tc.c_tconst_type (Decl_hint.hint env) in
    let attributes = tc.c_tconst_user_attributes in
    let enforceable =
      match Attrs.find SN.UserAttributes.uaEnforceable attributes with
      | Some { ua_name = (pos, _); _ } -> (pos, true)
      | None -> (Pos.none, false)
    in
    let reifiable =
      match Attrs.find SN.UserAttributes.uaReifiable attributes with
      | Some { ua_name = (pos, _); _ } -> Some pos
      | None -> None
    in
    Some
      {
        stc_abstract = typeconst_abstract_kind env tc.c_tconst_abstract;
        stc_name = tc.c_tconst_name;
        stc_as_constraint = as_constraint;
        stc_type = ty;
        stc_enforceable = enforceable;
        stc_reifiable = reifiable;
      }

let make_xhp_attr cv =
  Option.map cv.cv_xhp_attr (fun xai ->
      {
        xa_tag =
          (match xai.xai_tag with
          | None -> None
          | Some Required -> Some Required
          | Some LateInit -> Some Lateinit);
        xa_has_default = Option.is_some cv.cv_expr;
      })

let prop env cv =
  let cv_pos = fst cv.cv_id in
  let ty =
    FunUtils.hint_to_type_opt
      env
      ~is_lambda:false
      (Reason.Rglobal_class_prop cv_pos)
      (hint_of_type_hint cv.cv_type)
  in
  let const = Attrs.mem SN.UserAttributes.uaConst cv.cv_user_attributes in
  let lateinit = Attrs.mem SN.UserAttributes.uaLateInit cv.cv_user_attributes in
  let php_std_lib =
    Attrs.mem SN.UserAttributes.uaPHPStdLib cv.cv_user_attributes
  in
  {
    sp_name = cv.cv_id;
    sp_xhp_attr = make_xhp_attr cv;
    sp_type = ty;
    sp_visibility = cv.cv_visibility;
    sp_flags =
      PropFlags.make
        ~const
        ~lateinit
        ~lsb:false
        ~needs_init:(Option.is_none cv.cv_expr)
        ~abstract:cv.cv_abstract
        ~php_std_lib;
  }

and static_prop env cv =
  let (cv_pos, cv_name) = cv.cv_id in
  let ty =
    FunUtils.hint_to_type_opt
      env
      ~is_lambda:false
      (Reason.Rglobal_class_prop cv_pos)
      (hint_of_type_hint cv.cv_type)
  in
  let id = "$" ^ cv_name in
  let lateinit = Attrs.mem SN.UserAttributes.uaLateInit cv.cv_user_attributes in
  let lsb = Attrs.mem SN.UserAttributes.uaLSB cv.cv_user_attributes in
  let const = Attrs.mem SN.UserAttributes.uaConst cv.cv_user_attributes in
  let php_std_lib =
    Attrs.mem SN.UserAttributes.uaPHPStdLib cv.cv_user_attributes
  in
  {
    sp_name = (cv_pos, id);
    sp_xhp_attr = make_xhp_attr cv;
    sp_type = ty;
    sp_visibility = cv.cv_visibility;
    sp_flags =
      PropFlags.make
        ~const
        ~lateinit
        ~lsb
        ~needs_init:(Option.is_none cv.cv_expr)
        ~abstract:cv.cv_abstract
        ~php_std_lib;
  }

let method_type env m =
  let reactivity = FunUtils.fun_reactivity env m.m_user_attributes in
  let mut = FunUtils.get_param_mutability m.m_user_attributes in
  let ifc_decl = FunUtils.find_policied_attribute m.m_user_attributes in
  let returns_mutable = FunUtils.fun_returns_mutable m.m_user_attributes in
  let returns_void_to_rx =
    FunUtils.fun_returns_void_to_rx m.m_user_attributes
  in
  let return_disposable =
    FunUtils.has_return_disposable_attribute m.m_user_attributes
  in
  let params = FunUtils.make_params env ~is_lambda:false m.m_params in
  let capability =
    Decl_hint.aast_contexts_to_decl_capability env m.m_ctxs (fst m.m_name)
  in
  let ret =
    FunUtils.ret_from_fun_kind
      ~is_lambda:false
      ~is_constructor:(String.equal (snd m.m_name) SN.Members.__construct)
      env
      (fst m.m_name)
      m.m_fun_kind
      (hint_of_type_hint m.m_ret)
  in
  let arity =
    match m.m_variadic with
    | FVvariadicArg param ->
      assert param.param_is_variadic;
      Fvariadic (FunUtils.make_param_ty env ~is_lambda:false param)
    | FVellipsis p -> Fvariadic (FunUtils.make_ellipsis_param_ty p)
    | FVnonVariadic -> Fstandard
  in
  let tparams = List.map m.m_tparams (FunUtils.type_param env) in
  let where_constraints =
    List.map m.m_where_constraints (FunUtils.where_constraint env)
  in
  {
    ft_arity = arity;
    ft_tparams = tparams;
    ft_where_constraints = where_constraints;
    ft_params = params;
    ft_implicit_params = { capability };
    ft_ret = { et_type = ret; et_enforced = false };
    ft_reactive = reactivity;
    ft_flags =
      make_ft_flags
        m.m_fun_kind
        mut
        ~returns_mutable
        ~return_disposable
        ~returns_void_to_rx;
    ft_ifc_decl = ifc_decl;
  }

let method_ env m =
  let override = Attrs.mem SN.UserAttributes.uaOverride m.m_user_attributes in
  let (pos, _) = m.m_name in
  let has_dynamicallycallable =
    Attrs.mem SN.UserAttributes.uaDynamicallyCallable m.m_user_attributes
  in
  let php_std_lib =
    Attrs.mem SN.UserAttributes.uaPHPStdLib m.m_user_attributes
  in
  let ft = method_type env m in
  let reactivity =
    match ft.ft_reactive with
    | Pure (Some ty) ->
      begin
        match get_node ty with
        | Tapply ((_, cls), []) -> Some (Method_pure (Some cls))
        | _ -> None
      end
    | Pure None -> Some (Method_pure None)
    | Reactive (Some ty) ->
      begin
        match get_node ty with
        | Tapply ((_, cls), []) -> Some (Method_reactive (Some cls))
        | _ -> None
      end
    | Reactive None -> Some (Method_reactive None)
    | Shallow (Some ty) ->
      begin
        match get_node ty with
        | Tapply ((_, cls), []) -> Some (Method_shallow (Some cls))
        | _ -> None
      end
    | Shallow None -> Some (Method_shallow None)
    | Local (Some ty) ->
      begin
        match get_node ty with
        | Tapply ((_, cls), []) -> Some (Method_local (Some cls))
        | _ -> None
      end
    | Local None -> Some (Method_local None)
    | _ -> None
  in
  let sm_deprecated =
    Naming_attributes_deprecated.deprecated
      ~kind:"method"
      m.m_name
      m.m_user_attributes
  in
  {
    sm_name = m.m_name;
    sm_reactivity = reactivity;
    sm_type = mk (Reason.Rwitness pos, Tfun ft);
    sm_visibility = m.m_visibility;
    sm_deprecated;
    sm_flags =
      MethodFlags.make
        ~abstract:m.m_abstract
        ~final:m.m_final
        ~override
        ~dynamicallycallable:has_dynamicallycallable
        ~php_std_lib;
  }

let class_ ctx c =
  let (errs, result) =
    Errors.do_ @@ fun () ->
    let (_, cls_name) = c.c_name in
    let class_dep = Dep.Class cls_name in
    let env = { Decl_env.mode = c.c_mode; droot = Some class_dep; ctx } in
    let hint = Decl_hint.hint env in
    let (req_extends, req_implements) = split_reqs c in
    let (static_vars, vars) = split_vars c in
    let (constructor, statics, rest) = split_methods c in
    let sc_extends = List.map ~f:hint c.c_extends in
    let sc_uses = List.map ~f:hint c.c_uses in
    let sc_req_extends = List.map ~f:hint req_extends in
    let sc_req_implements = List.map ~f:hint req_implements in
    let sc_implements = List.map ~f:hint c.c_implements in
    let where_constraints =
      List.map c.c_where_constraints (FunUtils.where_constraint env)
    in
    let enum_type hint e =
      {
        te_base = hint e.e_base;
        te_constraint = Option.map e.e_constraint hint;
        te_includes = List.map e.e_includes hint;
        te_enum_class = e.e_enum_class;
      }
    in
    {
      sc_mode = c.c_mode;
      sc_final = c.c_final;
      sc_is_xhp = c.c_is_xhp;
      sc_has_xhp_keyword = c.c_has_xhp_keyword;
      sc_kind = c.c_kind;
      sc_name = c.c_name;
      sc_tparams = List.map c.c_tparams (FunUtils.type_param env);
      sc_where_constraints = where_constraints;
      sc_extends;
      sc_uses;
      sc_xhp_attr_uses = List.map ~f:hint c.c_xhp_attr_uses;
      sc_req_extends;
      sc_req_implements;
      sc_implements;
      sc_implements_dynamic = c.c_implements_dynamic;
      sc_consts = List.filter_map c.c_consts (class_const env c);
      sc_typeconsts = List.filter_map c.c_typeconsts (typeconst env c);
      sc_props = List.map ~f:(prop env) vars;
      sc_sprops = List.map ~f:(static_prop env) static_vars;
      sc_constructor = Option.map ~f:(method_ env) constructor;
      sc_static_methods = List.map ~f:(method_ env) statics;
      sc_methods = List.map ~f:(method_ env) rest;
      sc_user_attributes =
        List.map
          c.c_user_attributes
          ~f:Decl_hint.aast_user_attribute_to_decl_user_attribute;
      sc_enum_type = Option.map c.c_enum (enum_type hint);
    }
  in
  if not (Errors.is_empty errs) then (
    let reason =
      Errors.get_error_list errs
      |> Errors.convert_errors_to_string
      |> List.map ~f:(fun err ->
             Printf.sprintf
               "%s\nCallstack:\n%s"
               err
               (Caml.Printexc.raw_backtrace_to_string
                  (Caml.Printexc.get_callstack 500)))
      |> String.concat ~sep:"\n"
    in
    HackEventLogger.shallow_decl_errors_emitted reason;
    Errors.merge_into_current errs
  );
  result
