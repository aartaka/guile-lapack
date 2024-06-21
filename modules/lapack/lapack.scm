(define-module (lapack lapack)
  #:use-module (system foreign)
  #:use-module (system foreign-library)
  #:use-module (rnrs bytevectors)
  #:use-module (srfi srfi-1)
  #:export-syntax (;; Macros
                   define-lapack-float
                   define-lapack-double
                   define-lapack)
  #:export ( ;; Infra
            lapack
            lapack-fn
            ;; Constants
            +row-major+
            +column-major+
            +upper+
            +lower+
            +transpose+
            +no-transpose+
            ;; Functions (single+double)
            spotrf dpotrf
            spotrs dpotrs
            ssyev dsyev
            ssyevr dsyevr))

(define lapack (load-foreign-library "liblapacke.so"))
;; (define lapack (load-foreign-library "/home/aartaka/.guix-profile/lib/liblapacke.so"))

(define +row-major+ 101)
(define +column-major+ 102)
(define +upper+ (char->integer #\U))
(define +lower+ (char->integer #\L))
(define +transpose+ (char->integer #\T))
(define +no-transpose+ (char->integer #\N))

;; FIXME: Returns a garbage-filled memory area
(define* (2d-vector->lapack vector type #:optional (row-major? #t))
  (let* ((2d-vector-ref (lambda (v row col)
                          (vector-ref (vector-ref v row) col)))
         (rows (vector-length vector))
         (columns (vector-length (vector-ref vector 0)))
         (bytevector (make-bytevector (* (sizeof type) rows columns))))
    (do ((row 0 (1+ row)))
        ((= row rows))
      (do ((column 0 (1+ column)))
          ((= column columns))
        ((if (= type double)
             bytevector-ieee-double-native-set!
             bytevector-ieee-single-native-set!)
         bytevector
         (if row-major?
             (+ (* row columns) column)
             (+ (* column rows) row))
         (2d-vector-ref vector row column)
         (endianness little))))
    (format #t "~s~%" bytevector)
    (bytevector->pointer bytevector)))

(define* (lapack->2d-vector
          pointer type rows columns
          ;; naive presumption...
          #:optional (row-major? #t))
  (let ((bytevector (pointer->bytevector pointer (* (sizeof type) rows columns)))
        (2d-vector (list->vector
                    (map (lambda (x)
                           (make-vector columns 0))
                         (iota rows)))))
    (do ((row 0 (1+ row)))
        ((= row rows))
      (do ((column 0 (1+ column)))
          ((= column columns))
        (vector-set!
         (vector-ref 2d-vector row)
         column
         ((if (= type double)
              bytevector-ieee-double-native-ref
              bytevector-ieee-single-native-ref)
          bytevector
          (if row-major?
              (+ (* row columns) column)
              (+ (* column rows) row))
          (endianness little)))))
    2d-vector))

(define (c-struct-1 foreign type)
  (first (parse-c-struct foreign (list type))))
(define (make-c-struct-1 type value)
  (make-c-struct (list type) (list value)))

(define (lapack-fn name args return)
  (foreign-library-function
   lapack
   (string-append "LAPACKE_" name)
   #:return-type return
   #:arg-types args))

(define-syntax-rule (define-lapack-double name documentation (arg type) ...)
  (define (name layout arg ...)
    documentation
    ((lapack-fn (symbol->string (quote name))
                (list int type ...) int)
     layout arg ...)))
(define-syntax-rule (define-lapack-float name documentation (arg type) ...)
  (define (name layout arg ...)
    documentation
    ((lapack-fn (symbol->string (quote name))
                (list int type ...) int)
     layout arg ...)))

(define-syntax-rule (define-lapack (float-name double-name)
                      documentation
                      . args)
  (begin
    (define-lapack-float float-name documentation
      . args)
    (define-lapack-double double-name documentation
      . args)))

(define-lapack (spotrf dpotrf)
  "Cholesky factorization of a real symmetric positive definite matrix A"
  (uplo uint8) (n int) (a '*) (lda int))
(define-lapack (spotrs dpotrs)
  "Solve a system of linear equations A*X = B with a symmetric
 positive definite matrix A using the Cholesky factorization
 A = U**T*U or A = L*L**T computed by DPOTRF/SPOTRF"
  (uplo uint8) (n int) (nrhs int) (a '*) (lda int) (b '*) (ldb int))
(define-lapack (ssyev dsyev)
  "Compute the eigenvalues and, optionally, the left and/or right eigenvectors for SY matrices"
  (jobz uint8) (uplo uint8) (n int) (a '*) (lda int) (w '*))
(define-lapack-float ssyevr
  "SSYEVR computes the eigenvalues and, optionally, the left and/or right eigenvectors for SY matrices"
  (jobz uint8) (range uint8) (uplo uint8)
  (n int) (a '*) (lda int)
  (vl float) (vu float)
  (il int) (iu int) (abstol float)
  (m '*) (w '*)
  (z '*) (ldz int) (isuppz '*))
(define-lapack-double dsyevr
  "DSYEVR computes the eigenvalues and, optionally, the left and/or right eigenvectors for SY matrices"
  (jobz uint8) (range uint8) (uplo uint8)
  (n int) (a '*) (lda int)
  (vl double) (vu double)
  (il int) (iu int) (abstol double)
  (m '*) (w '*)
  (z '*) (ldz int) (isuppz '*))

;; TODO:
;; bdsdc bdsqr disna gbbrd gbcon gbequ gbequb gbrfs gbrfsx gbsv gbsvx gbsvxx gbtrf
;; gbtrs gebak gebal gebrd gecon geequ geequb gees geesx geev geevx gehrd gejsv
;; gelqf gels gelsd gelss gelsy geqlf geqp3 geqpf geqrf geqrfp gerfs gerfsx gerqf
;; gesdd gesv gesvd gesvj gesvx gesvxx getrf getri getrs ggbak ggbal gges ggesx
;; ggev ggevx ggglm gghrd gglse ggqrf ggrqf ggsvd ggsvp gtcon gtrfs gtsv gtsvx
;; gttrf gttrs hgeqz hsein hseqr opgtr opmtr orgbr orghr orglq orgql orgqr orgrq
;; orgtr ormbr ormhr ormlq ormql ormqr ormrq ormrz ormtr pbcon pbequ pbrfs pbstf
;; pbsv pbsvx pbtrf pbtrs pftrf pftri pftrs pocon poequ poequb porfs porfsx posv
;; posvx posvxx potri ppcon ppequ pprfs ppsv ppsvx pptrf pptri pptrs
;; pstrf ptcon pteqr ptrfs ptsv ptsvx pttrf pttrs sbev sbevd sbevx sbgst sbgv
;; sbgvd sbgvx sbtrd sfrk spcon spev spevd spevx spgst spgv spgvd spgvx sprfs spsv
;; spsvx sptrd sptrf sptri sptrs stebz stedc stegr stein stemr steqr sterf stev
;; stevd stevr stevx sycon syequb syevd syevx sygst sygv sygvd sygvx
;; syrfs syrfsx sysv sysvx sysvxx sytrd sytrf sytri sytrs tbcon tbrfs tbtrs tfsm
;; tftri tfttp tfttr tgevc tgexc tgsen tgsja tgsna tgsyl tpcon tprfs tptri tptrs
;; tpttf tpttr trcon trevc trexc trrfs trsen trsna trsyl trtri trtrs trttf trttp
;; tzrzf
