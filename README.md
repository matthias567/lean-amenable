# Amenable Groups in Lean 

The goal of this project is an implementation of amenable Groups in Lean. 

## Overview

All files are located in the `src` folder. The most important files contain the following
statements and definitions.

* demo/demo-complete.lean   : A demonstration, given in a short talk in September 2022.
* def_amenable.lean         : Definition of amenability (via left-invariant means)
* extension.lean            : Extensions of amenable groups are amenable.
* finite.lean               : Finite groups are amenable.
* Folner_amenable.lean      : Definition of Folner sets and Folner amenability. 
                              Folner amenable groups are amenable.
* Folner_example.lean       : The integers \Z admit a Folner set. 
                              Thus, \Z is amenable.
* free_groups.lean          : Free groups (of rank at least 2) are not amenable.
* quotient.lean             : Quotients of amenable groups are amenable. Amenability is
                              preserved by isomorphisms.
* subgroup.lean             : Subgroups of amenable groups are amenable.


## References

* Chapter 9 in C. Löh, *Geometric Group Theory*. An introduction. Regensburg, 2017. 
* <https://en.wikipedia.org/wiki/Amenable_group>
* Introduction of A.L.T. Paterson, *Amenability*. Providence, 1988.

## Installation Guideline 

* Install Lean 3:
  https://leanprover-community.github.io/get_started.html 
* Add the mathlib to the project:
  https://leanprover-community.github.io/leanproject.html


