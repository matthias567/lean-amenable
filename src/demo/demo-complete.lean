/-
Copyright (c) 2022 Matthias Uschold. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Matthias Uschold.
-/

import ..free_groups 
import ..subgroup 
open function 
open bounded_continuous_function

/-!
# DEMO : Implementation of Amenable Groups in Lean 

In this file, we demonstrate the implementation of amenable groups in Lean. 
This is intended to be done during a talk 


## Main Steps

* Definition of Amenability
* Definition of (left invariant) means
* Theorem: If a group contains a free group (more precisely: 
    of rank at least 2), then it is not amenable

## Note 

We sometimes use the namespace 'hidden' in this file to avoid name clashes with existing declarations 
(mainly for amenable, etc.). 
-/


namespace hidden 


variables (G:Type*) [group G]


structure mean  
:= mk ::
  (lin_map : (bounded_continuous_function G ℝ) →ₗ[ℝ] ℝ)
  (normality : lin_map (const G 1) = 1)
  (positivity: ∀ {f : bounded_continuous_function G ℝ}, 
                          (∀ (x:G), f x ≥ 0) → lin_map f ≥ 0)

structure left_invariant_mean 
  extends mean G
:= mk ::
  (left_invariance: ∀ g:G , ∀ f, lin_map (g•f) = lin_map f)



def amenable 
  : Prop 
:= nonempty (left_invariant_mean G)


end hidden 


section 
/-!
### Example 

If a group G contains a free group 
  (more precisely: If there is an injective group homomorphisms from a free group (of rank at least 2) into 
  the group), then it is not amenable

-/


theorem contains_free_implies_not_amenable 
  {G : Type*} [group G]
  {X : Type*}
  {x y : X}
  (x_neq_y : x ≠ y) -- needs to be added later 
  {i           : free_group X →* G}
  (i_injective : injective i)
  : ¬ amenable G 
:= begin 
  assume G_amenable : amenable G,
  have range_amenable : amenable i.range 
      := amenable_of_subgroup i.range G_amenable,
  have iso_freeX : i.range ≃* free_group X 
      := iso_range_of_injective' i_injective, 
  have freeX_amenable : amenable (free_group X)
      := amenable_of_iso iso_freeX range_amenable,
  
  have freeX_not_amenable : ¬ amenable (free_group X)
      := not_amenable_of_free x_neq_y,
  contradiction, 
end 

#check @not_amenable_of_free




end 
