/-
Copyright (c) 2022 Matthias Uschold. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Matthias Uschold.
-/

import .def_amenable
import data.set        -- basics on sets
import data.set.finite -- basics on finite sets
import data.finset     -- type-level finite sets

import algebra.big_operators.basic
import algebra.big_operators.order

import .aux_lemmas_sums


/-!
# Finite groups are amenable

In this file, we show that finite groups are amenable. 
We do this via an explicit construction of a left invariant mean. 

## Main Definitions

- `inv_mean_of_fin`   : The explicitely constructed, left invariant mean  


## Main Statements

- `amenable_of_finite`: Finite groups are amenable 


## References 
* [C. Löh, *Geometric Group Theory*, Example 9.1.2][loeh17]
* <https://en.wikipedia.org/wiki/Amenable_group>


## Tags

amenable finite groups, finite, amenable

-/



open_locale big_operators -- to enable ∑ notation

open classical




namespace amenable_finite

variables
{G:Type*}
[group G] 
(G_fin: fintype G)

include G_fin  

/-!The finset given by all elements in G-/
local notation `setG` := (@finset.univ G G_fin)

/--The averaging map, given by summing all values of f,
then dividing by the cardinality of G-/
noncomputable def avg_map 
  : (bounded_continuous_function G ℝ) → ℝ
:= (λ f, (finset.card setG:ℝ)⁻¹ * ∑ x in setG, f x)

lemma avg_map_add'
  : ∀ f g, (avg_map G_fin) (f+g) = (avg_map G_fin) f + (avg_map G_fin) g 
:= begin 
  assume f g,
  calc  (avg_map G_fin) (f+g)
      = (finset.card setG :ℝ)⁻¹ 
            * ∑ x in setG, (f+g) x 
        : by simp[avg_map]
  ... = (finset.card setG :ℝ)⁻¹ 
            * ∑ x in setG, (f x + g x)
        : by {
          congr' 1,
        }
  ... = (finset.card setG :ℝ)⁻¹ *
        (∑ x in setG, f x + ∑ x in setG, g x)
        : by simp [finset.sum_add_distrib]
  ... = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, f x +
        (finset.card setG :ℝ)⁻¹ * ∑ x in setG, g x
        : by ring 
  ... = (avg_map G_fin) f + (avg_map G_fin) g 
        : by simp[avg_map],
end 

lemma avg_map_smul'
  : ∀ (r:ℝ) f, (avg_map G_fin) (r•f) = r•((avg_map G_fin) f)  
:= begin
  assume r f,
  calc  (avg_map G_fin) (r•f)
      = (finset.card setG :ℝ)⁻¹ 
            * ∑ x in setG, (r•f) x
        : by simp[avg_map]
  ... = (finset.card setG :ℝ)⁻¹ 
            * ∑ x in setG, r * f x
        : by simp 
  ... = (finset.card setG :ℝ)⁻¹ 
            * ( r *  ∑ x in setG,  f x)
        : by simp [sum_scalar r]
  ... = r * ((finset.card setG :ℝ)⁻¹ 
            *  ∑ x in setG,  f x)
        : by ring 
  ... = r * (avg_map G_fin) f  
        : by simp[avg_map]
  ... = r•((avg_map G_fin) f)
        : by simp,
end 

-- The averaging map is a linear map
noncomputable def avg_linmap 
  : (bounded_continuous_function G ℝ) →ₗ[ℝ] ℝ
:= linear_map.mk (avg_map G_fin) 
      (avg_map_add' G_fin) (avg_map_smul' G_fin)

lemma avg_map_norm 
  : (avg_linmap G_fin) ((bounded_continuous_function.const G (1:ℝ))) = 1
:= begin 
  -- later, we need that |G| ≠ 0
  have card_neq0 : finset.card setG ≠ 0,
  {
    have : setG ≠ ∅,
    { -- this is not the most straightforward way
      let x0 : G  := classical.choice has_one.nonempty,
      have : x0 ∈ setG := finset.mem_univ x0,
      exact finset.ne_empty_of_mem this,
    },
    finish,
  }, 

  calc  (avg_linmap G_fin) ((bounded_continuous_function.const G (1:ℝ))) 
      = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, 
                      ((bounded_continuous_function.const G (1:ℝ)) x)
        : by simp[avg_linmap, avg_map]
  ... = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, 1
        : by simp
  ... = (finset.card setG :ℝ)⁻¹ * ((finset.card setG) * (1:ℝ))
        : by simp 
  ... = (finset.card setG :ℝ)⁻¹ * (finset.card setG)
        : by simp 
  ... = (1:ℝ)
        : by simp [nat.cast_ne_zero.mpr card_neq0],
end

lemma avg_map_pos 
  : ∀ (f : bounded_continuous_function G ℝ), 
                    (∀ (x:G), f x ≥ 0) → (avg_linmap G_fin) f ≥ 0
:= begin 
  assume f :bounded_continuous_function G ℝ,
  assume f_nonneg:  ∀ (x:G), f x ≥ 0,

  have : ∀ x ∈ setG, f x ≥ 0 
    := by tauto,

  have sum_nonneg:  ∑ x in setG, f x ≥ 0,
  {
    calc (0:ℝ) 
        = ∑ x in setG, (0:ℝ) 
            : by simp 
    ... ≤ ∑ x in setG, f x
            : finset.sum_le_sum this,
  },

  have card_nonneg : (finset.card setG:ℝ)⁻¹ ≥ 0 
            := by simp[zero_le (finset.card setG)],
  
  calc (avg_linmap G_fin) f 
      = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, f x
        : by simp[avg_linmap, avg_map]
  ... ≥ 0 
        : mul_nonneg card_nonneg sum_nonneg,
end 


/--The excplicit mean on a finite group-/
noncomputable def mean_fin 
  : mean G 
:= mean.mk (avg_linmap G_fin) (avg_map_norm _) (avg_map_pos _)

omit G_fin 

lemma perm_left_inverse {G:Type*} [group G]
  (g: G) 
  : function.left_inverse (left_mul g⁻¹) (left_mul g)
:= begin 
  unfold function.left_inverse,
  assume x:G,
  calc  left_mul g⁻¹ (left_mul g x) 
      = left_mul g⁻¹ (g*x)
        : by simp [left_mul] 
  ... = g⁻¹ * (g*x)  
        : by simp [left_mul] 
  ... = x
        :by group,
end 

lemma perm_right_inverse {G:Type*} [group G]
  (g: G) 
  : function.right_inverse (left_mul g⁻¹) (left_mul g)
:= begin 
  unfold function.right_inverse,
  assume x:G,
  calc  left_mul g (left_mul g⁻¹ x) 
      = left_mul g (g⁻¹*x)
        : by simp [left_mul] 
  ... = g * (g⁻¹*x)  
        : by simp [left_mul] 
  ... = x
        :by group,
end 


def left_mul_perm {G:Type*} [group G]
  (g: G) 
  : equiv.perm G 
:= equiv.mk (left_mul g) (left_mul g⁻¹) 
          (perm_left_inverse g) (perm_right_inverse g)




include G_fin 



/--This given mean is left invariant-/
lemma avg_map_left_inv
  : ∀(g:G), ∀(f: bounded_continuous_function G ℝ), 
      (avg_linmap G_fin) (left_translate g f) = (avg_linmap G_fin) f
:= begin 
	assume g : G,
	assume f,

	-- we first prove that the sums are equal
	have sums_eq: ∑ x in setG, f (g⁻¹*x)
							= ∑ x in setG, f x,
	{
		let σ : equiv.perm G := left_mul_perm g⁻¹,
		exact equiv.perm.sum_comp σ  setG _ (by norm_num),
	},

	calc  (avg_linmap G_fin) (left_translate g f) 
	    = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, (left_translate g f) x
			 	: by simp[avg_linmap, avg_map]
	... = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, f (g⁻¹*x)
				: by congr';apply finset.sum_congr
	... = (finset.card setG :ℝ)⁻¹ * ∑ x in setG, f x 
				: congr_arg (has_mul.mul (finset.card setG :ℝ)⁻¹) sums_eq
	... = (avg_linmap G_fin) f 
				: by simp [avg_linmap, avg_map],
end 



/--The explicit left invariant mean on a finite group-/
noncomputable def inv_mean_of_fin 
  : left_invariant_mean G 
:= left_invariant_mean.mk (mean_fin G_fin) (avg_map_left_inv G_fin)

omit G_fin 


/--Finite groups are amenable-/
theorem amenable_of_finite
(G:Type*)
[group G] 
[topological_space G]
[discrete_topology G]
(G_fin: fintype G) 
: amenable G 
:= amenable_of_invmean (inv_mean_of_fin G_fin)

end amenable_finite
