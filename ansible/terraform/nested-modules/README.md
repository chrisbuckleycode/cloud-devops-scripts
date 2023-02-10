This is a work-in-progress effort to try to recreate an unusual but sometimes encountered Terraform convention used at some companies I've consulted for.

These are nested modules were variables assignments in tfvars are in the form of multi-dimensional arrays.

They have a high learning curve and are difficult to develop and refactor. However, they allow for an entire infrastructure to be configured in a single tfvars file with nested variables.
