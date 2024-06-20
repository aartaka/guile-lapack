# Guile LAPACK bindings

This library binds some (not all, open to contributions!) of the
LAPACK functions in Guile, using the LAPACKE C layer as the
target. Most functions are thin wrappers over LAPACKE, with a
potential for a higher-level interface (sometime later?)

Functions are added on an as needed basis (as used in
[Mgamma](https://github.com/aartaka/mgamma).) Contributions welcome!

## Installation

Ensure that you have the `modules/` directory in your `GUILE_LOAD_PATH`/`%load-path` and load it.
You might need to adjust the directory paths in `modules/lapack/lapack.scm` to make LAPACKE .so-s discoverable.

Environment management is easier with Guix, that's why there's guix.scm.
You can also install this repo as a Guix channel:
``` scheme
;; .config/guix/channels.scm
(cons*
 (channel
  (name 'guile-lapack)
  (url "https://github.com/aartaka/guile-lapack.git")
  (branch "master"))
  ...
  %default-channels)
```
Both guix.scm and the channel provide `guile-lapack-git` package with the fresh code.

## Names & How to Use The Library

Most bindings follow the LAPACKE names, except that `LAPACKE_` prefix is dropped.

Notice that this extremely succinct naming means that many symbols in
the programs one writes may (but are unlikely to due to extremely
unreadable names LAPACK uses) collide with the names provided by this
library. Thus, use the provided modules with suitable prefixes instead
of importing them raw:

``` scheme
(use-modules ((lapack lapack) #:prefix lapack:))
```

See the exported functions/constants list using Guile-native introspection facilities:
``` scheme
(use-modules ((lapack lapack) #:prefix lapack:))
,apropos lapack: 
;; (lapack lapack): lapack:+lower+
;; (lapack lapack): lapack:+row-major+
;; (lapack lapack): lapack:define-lapack
;; (lapack lapack): lapack:lapack-fn	#<procedure lapack-fn (name type args return)>
;; (lapack lapack): lapack:dsyev	#<procedure dsyev (layout jobz uplo n a lda w)>
;; (lapack lapack): lapack:+transpose+
;; (lapack lapack): lapack:dpotrs	#<procedure dpotrs (layout uplo n nrhs a lda b ldb)>
;; ...
```
