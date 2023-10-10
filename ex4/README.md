# Explanation

The diff might occur because merge and rebase approaches the operation differently.

Merge is taking two branches and integrates history of one into another, resulting in detailed history of changes. 

Rebase is more linear. It moves series of commits on top of selected branch and does not necessarily preserve detailed history of changes. 

The change occured because of cherry picking commits. After resolving issues it changed its SHA, resulting in Git having issue with understanding that no change in file but a change in sha is actually a change.

All in all: I am not sure if I completed this task correctly.

# My diff

```
diff --git a/libvirt.pp b/libvirt.pp
index 15baa22..c37b5ea 100644
--- a/libvirt.pp
+++ b/libvirt.pp
@@ -35,13 +35,8 @@
 #
 # [*libvirt_cpu_model_extra_flags*]
 #   (optional) This allows specifying granular CPU feature flags when
-<<<<<<< HEAD
-#   specifying CPU models. Only valid, if cpu_mode and cpu_model
-#   attributes are specified and only if cpu_mode="custom".
-=======
 #   specifying CPU models. Only has effect if cpu_mode is not set
 #   to 'none'.
->>>>>>> origin/stein
 #   Defaults to undef
 #
 # [*libvirt_snapshot_image_format*]
@@ -283,20 +278,14 @@ class nova::compute::libvirt (
     validate_legacy(String, 'validate_string', $libvirt_cpu_model)
     nova_config {
       'libvirt/cpu_model': value => $libvirt_cpu_model;
-      'libvirt/cpu_model_extra_flags': value => $libvirt_cpu_model_extra_flags;
     }
   } else {
     nova_config {
       'libvirt/cpu_model': ensure => absent;
-      'libvirt/cpu_model_extra_flags': ensure => absent;
     }
     if $libvirt_cpu_model {
       warning('$libvirt_cpu_model requires that $libvirt_cpu_mode => "custom" and will be ignored')
     }
-
-    if $libvirt_cpu_model_extra_flags {
-      warning('$libvirt_cpu_model_extra_flags requires that $libvirt_cpu_mode => "custom" and will be ignored')
-    }
   }
 
   if $libvirt_cpu_mode_real != 'none' {
```