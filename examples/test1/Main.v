Require Import String.

(** `]a, b[ is a unmatched code block. (rendering will broken same as coqdoc) *)
(** [[1;2;3] ++ []] is a nested code block example. *)
Definition x := 123.

Section Export.
End Export.

Module Mod.
End Mod.

Module Require.
End Require.

Import Require.

Module HB.
End HB.
From HB Require Import structures.

Locate "_ + _".

Inductive light : Set :=
| Red     (**r Aka *)
| Yellow  (**r Ki  *)
| Blue.   (**r Ao  *)
