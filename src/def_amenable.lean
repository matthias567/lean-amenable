/-
Copyright (c) 2022 Matthias Uschold. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Matthias Uschold.
-/

import .mean 

/-!
# Amenable Groups

We introduce the concept of amenable groups. 
A group is called `amenable` if there exists a left-invariant mean,
i.e. a mean (a positive, normalised linear function L^∞ (G, ℝ) → ℝ )
that is invariant under left translation of the argument. 


## Main Definitions

- `left_invariant_mean`  : mean with the property of being left-invariant
- `right_invariant_mean` : Alternative variant
- `bi_invariant_mean`    : Alternative variant
- `amenable`             : amenability of a group (defined by nonemptiness of left_invariant_mean)


We will see in `right_bi_invariance.lean` that the alternative variants yield
the same notion of amenability 

## Implementation Notes

The notion of a mean is already defined in the file `mean.lean`. This 
file defines the left translate of a function and 

This file defines amenability by regarding all groups with their discrete topology,
thus enabling us to use `bounded_continuous_function`. 
If you want to consider amenability on (non-discrete) 
topological groups, one needs to change some definitions.

## References 
* [C. Löh, *Geometric Group Theory*, Definition 9.1.1][loeh17]
* <https://en.wikipedia.org/wiki/Amenable_group>
* [A.L.T. Paterson, *Amenability*, Definition 0.2][Paterson1988]

## Tags

amenable, amenability, invariant mean, left invariant mean
-/

open mean 
open classical
open bounded_continuous_function

variables (G:Type*) [group G]

/-- left-translate of a function by translating the argument -/
noncomputable def left_translate {G:Type*} [group G]
  (g : G)
  (f : bounded_continuous_function G ℝ)
  : bounded_continuous_function G ℝ
:= bcont_precomp_discrete (λ h, g⁻¹*h) f

@[simp]
lemma left_translate_eval {G:Type*} [group G]
  {g : G}
  {f : bounded_continuous_function G ℝ}
: ∀(x:G), left_translate g f x = f(g⁻¹*x)
:= by tauto 



noncomputable instance left_translate_action {G:Type*} [group G]
  : mul_action G (bounded_continuous_function G ℝ)
:= @mul_action.mk G  (bounded_continuous_function G ℝ) _ 
    (has_smul.mk (λ g f, left_translate g f))
    (begin 
      assume f : bounded_continuous_function G ℝ,
      simp,
      ext x,
      by simp,
    end)
    (begin 
      assume g h f,
      ext x,
      simp, 
      congr' 1,
      by simp [mul_assoc],
    end )
    
@[simp]
lemma left_translate_smul_simp {g:G} {f:bounded_continuous_function G ℝ}
  : g•f = left_translate g f 
:= by refl 


/-- right-translate of a function by translating the argument -/
noncomputable def right_translate {G:Type*} [group G]
  (g : G)
  (f : bounded_continuous_function G ℝ)
  : bounded_continuous_function G ℝ
:= bcont_precomp_discrete (λ h, h*g) f

@[simp]
lemma right_translate_eval {G:Type*} [group G]
  {g : G}
  {f : bounded_continuous_function G ℝ}
: ∀(x:G), right_translate g f x = f(x*g)
:= by tauto 



/--It is an easy (but important) fact that left and right-translation commute-/
lemma left_right_translate_commute 
  {G:Type*} [group G]
  {g h: G}
  {f : bounded_continuous_function G ℝ}
  : right_translate h (left_translate g f) = left_translate g (right_translate h f)
:= begin
  ext x,
  simp,
  congr' 1,
  by simp [mul_assoc],
end 


section invariance_structures

/-!
### Invariance structures

We will defines structures for left-, right- and bi-invariant means.

-/

/--Left invariant means are means that are left invariant-/
structure left_invariant_mean (G:Type*) [group G]
  extends mean G
:= mk ::
  (left_invariance: 
    ∀(g:G), ∀(f: bounded_continuous_function G ℝ), 
      lin_map (g•f) = lin_map f)

instance : has_coe (left_invariant_mean G) (mean G) 
      := {coe := left_invariant_mean.to_mean}

@[simp]
lemma left_invariant_mean_eval 
  {m: left_invariant_mean G}
  {f: bounded_continuous_function G ℝ}
  : m f = m.to_mean f 
:= by refl 

/--Analogously: right-invariant means -/
structure right_invariant_mean (G:Type*) [group G]
  extends mean G
:= mk ::
  (right_invariance: 
    ∀(g:G), ∀(f: bounded_continuous_function G ℝ), 
      lin_map (right_translate g f) = lin_map f)

instance right_inv_mean_coe : has_coe (right_invariant_mean G) (mean G) 
      := {coe := right_invariant_mean.to_mean}

/--Analogously: bi-invariant means -/
structure bi_invariant_mean (G:Type*) [group G]
  extends left_invariant_mean G
:= mk ::
  (right_invariance: 
    ∀(g:G), ∀(f: bounded_continuous_function G ℝ), 
      lin_map (right_translate g f) = lin_map f)

instance : has_coe (bi_invariant_mean G) (left_invariant_mean G)
    := {coe := bi_invariant_mean.to_left_invariant_mean}


end invariance_structures

/-- A group is amenable if there exists a left-invariant mean-/
@[simp]
def amenable (G:Type*) [group G]
  [topological_space G]
  [discrete_topology G]
 : Prop 
:= nonempty (left_invariant_mean G) 


/-- For amenable groups, we can pick a left-invariant mean. 
This is a noncomputable process.
-/
noncomputable def invmean_of_amenable {G:Type*} [group G]
  (G_am : amenable G)
 : left_invariant_mean G 
:= classical.some (classical.exists_true_of_nonempty G_am)

/--If we can exhibit a mean, the group is amenable-/
lemma amenable_of_invmean 
  {G:Type*} [group G]
  (m : left_invariant_mean G)
  : amenable G 
:= nonempty.intro m

