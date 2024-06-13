(define-module (guile-lapack-package)
 #:use-module (gnu packages guile)
 #:use-module (gnu packages maths)
 #:use-module (guix packages)
 #:use-module (guix gexp)
 #:use-module (guix utils)
 #:use-module (guix build-system guile)
 #:use-module (guix git-download)
 #:use-module ((guix licenses) #:prefix license:))

(define-public guile-lapack-git
  (package
    (name "guile-lapack-git")
    (version "0.0.1")
    (source (local-file ".."
                        "guile-lapack-git-checkout"
                        #:recursive? #t
                        #:select? (or (git-predicate (dirname (current-source-directory)))
                                      (const #t))))
    (build-system guile-build-system)
    (arguments
     (list #:source-directory "modules"
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'build 'substitute-lapacke-so
                 (lambda _
                   (let ((lapacke (string-append #$(this-package-input "lapack")
                                                 "/lib/liblapacke.so")))
                     (substitute* '("modules/lapack/lapack.scm")
                       (("liblapacke.so")
                        lapacke))))))))
    (native-inputs (list guile-3.0))
    (inputs (list guile-3.0 lapack))
    (home-page "https://github.com/aartaka/guile-lapack")
    (synopsis "Bindings for LAPACK in Guile.")
    (description "Scheme wrapper around liblapacke.so.")
    (license license:gpl3+)))

guile-lapack-git
