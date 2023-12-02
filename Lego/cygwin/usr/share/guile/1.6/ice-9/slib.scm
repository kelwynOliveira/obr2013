;;;; slib.scm --- definitions needed to get SLIB to work with Guile
;;;;
;;;;	Copyright (C) 1997, 1998, 2000, 2001, 2002, 2003, 2004 Free Software Foundation, Inc.
;;;;
;;;; This file is part of GUILE.
;;;; 
;;;; GUILE is free software; you can redistribute it and/or modify it
;;;; under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation; either version 2, or (at your
;;;; option) any later version.
;;;; 
;;;; GUILE is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; General Public License for more details.
;;;; 
;;;; You should have received a copy of the GNU General Public License
;;;; along with GUILE; see the file COPYING.  If not, write to the
;;;; Free Software Foundation, Inc., 59 Temple Place, Suite 330,
;;;; Boston, MA 02111-1307 USA
;;;;
;;;; As a special exception, the Free Software Foundation gives permission
;;;; for additional uses of the text contained in its release of GUILE.
;;;;
;;;; The exception is that, if you link the GUILE library with other files
;;;; to produce an executable, this does not by itself cause the
;;;; resulting executable to be covered by the GNU General Public License.
;;;; Your use of that executable is in no way restricted on account of
;;;; linking the GUILE library code into it.
;;;;
;;;; This exception does not however invalidate any other reasons why
;;;; the executable file might be covered by the GNU General Public License.
;;;;
;;;; This exception applies only to the code released by the
;;;; Free Software Foundation under the name GUILE.  If you copy
;;;; code from other Free Software Foundation releases into a copy of
;;;; GUILE, as the General Public License permits, the exception does
;;;; not apply to the code that you add in this way.  To avoid misleading
;;;; anyone as to the status of such modified files, you must delete
;;;; this exception notice from them.
;;;;
;;;; If you write modifications of your own for GUILE, it is your choice
;;;; whether to permit this exception to apply to your modifications.
;;;; If you do not wish that, delete this exception notice.
;;;;
(define-module (ice-9 slib)
  :export (slib:load
	   implementation-vicinity
	   library-vicinity
	   home-vicinity
	   scheme-implementation-type
	   scheme-implementation-version
	   make-random-state
	   <? <=? =? >? >=?
	   require)
  :no-backtrace)



(define (eval-load <filename> evl)
  (if (not (file-exists? <filename>))
      (set! <filename> (string-append <filename> (scheme-file-suffix))))
  (call-with-input-file <filename>
    (lambda (port)
      (let ((old-load-pathname *load-pathname*))
	(set! *load-pathname* <filename>)
	(do ((o (read port) (read port)))
	    ((eof-object? o))
	  (evl o))
	(set! *load-pathname* old-load-pathname)))))



(define-public slib:exit quit)
(define-public slib:error error)
(define-public slib:warn warn)
(define-public slib:eval (lambda (x) (eval x slib-module)))
(define defmacro:eval (lambda (x) (eval x (interaction-environment))))
(define logical:logand logand)
(define logical:logior logior)
(define logical:logxor logxor)
(define logical:lognot lognot)
(define logical:ash ash)
(define logical:logcount logcount)
(define logical:integer-length integer-length)
(define logical:bit-extract bit-extract)
(define logical:integer-expt integer-expt)
(define logical:ipow-by-squaring ipow-by-squaring)
(define-public slib:eval-load eval-load)
(define-public slib:tab #\tab)
(define-public slib:form-feed #\page)

(define slib-module (current-module))

(define (defined? symbol)
  (module-defined? slib-module symbol))

(define slib:features
  (append '(source
	    eval
	    abort
	    alist
	    defmacro
	    delay
	    dynamic-wind
	    full-continuation
	    hash
	    hash-table
	    line-i/o
	    logical
	    multiarg/and-
	    multiarg-apply
	    promise
	    rev2-procedures
	    rev4-optional-procedures
	    string-port
	    with-file)

	  (if (defined? 'getenv)
	      '(getenv)
	      '())

	  (if (defined? 'current-time)
	      '(current-time)
	      '())

	  (if (defined? 'system)
	      '(system)
	      '())

	  (if (defined? 'char-ready?)
	      '(char-ready?)
	      '())

	  (if (and (string->number "0.0") (inexact? (string->number "0.0")))
	      '(inexact)
	      '())

	  (if (rational? (string->number "1/19"))
	      '(rational)
	      '())

	  (if (real? (string->number "0.0"))
	      '(real)
	      ())

	  (if (complex? (string->number "1+i"))
	      '(complex)
	      '())

	  (let ((n (string->number "9999999999999999999999999999999")))
	    (if (and n (exact? n))
		'(bignum)
		'()))))


;; The array module specified by slib 3a1 is not the same as what guile
;; provides, so we must remove `array' from the features list.
;;
;; The main difference is `create-array' which is similar to
;; `make-uniform-array', but the `Ac64' etc prototype procedures incorporate
;; an initial fill element into the prototype.
;;
;; Believe the array-for-each module will need to be taken from slib when
;; the array module is taken from there, since what the array module creates
;; won't be understood by the guile functions.  So remove `array-for-each'
;; from the features list too.
;;
;; Also, slib 3a1 array-for-each specifies an `array-map' which is not in
;; guile (but could be implemented quite easily).
;;
;; ENHANCE-ME: It'd be nice to implement what's necessary, since the guile
;; functions should be more efficient than the implementation in slib.
;;
;; FIXME: Since the *features* variable is shared by slib and the guile
;; core, removing these feature symbols has the unhappy effect of making it
;; look like they aren't in the core either.  Let's assume that arrays have
;; been present unconditionally long enough that no guile-specific code will
;; bother to test.  An alternative would be to make a new separate
;; *features* variable which the slib stuff operated on, leaving the core
;; mechanism alone.  That might be a good thing anyway.
;;
(set! *features* (delq 'array          *features*))
(set! *features* (delq 'array-for-each *features*))


;;; FIXME: Because uers want require to search the path, this uses
;;; load-from-path, which probably isn't a hot idea.  slib
;;; doesn't expect this function to search a path, so I expect to get
;;; bug reports at some point complaining that the wrong file gets
;;; loaded when something accidentally appears in the path before
;;; slib, etc. ad nauseum.  However, the right fix seems to involve
;;; changing catalog:get in slib/require.scm, and I don't expect
;;; Aubrey will integrate such a change.  So I'm just going to punt
;;; for the time being.
(define (slib:load name)
  (save-module-excursion
   (lambda ()
     (set-current-module slib-module)
     (let ((errinfo (catch 'system-error
			   (lambda ()
			     (load-from-path name)
			     #f)
			   (lambda args args))))
       (if (and errinfo
		(catch 'system-error
		       (lambda ()
			 (load-from-path
			  (string-append name ".scm"))
			 #f)
		       (lambda args args)))
	   (apply throw errinfo))))))

(define-public slib:load-source slib:load)
(define defmacro:load slib:load)

(define slib-parent-dir
  (let* ((path (%search-load-path "slib/require.scm")))
    (if path
	(substring path 0 (- (string-length path) 17))
	(error "Could not find slib/require.scm in " %load-path))))

(define (implementation-vicinity)
  (string-append slib-parent-dir "/"))
(define (library-vicinity)
  (string-append (implementation-vicinity) "slib/"))
(define home-vicinity
  (let ((home-path (getenv "HOME")))
    (lambda () home-path)))
(define (scheme-implementation-type) 'guile)
(define (scheme-implementation-version) "")

;; legacy from r3rs, but slib says all implementations provide these
;; ("Legacy" section of the "Miscellany" node in the manual)
(define-public t   #t)
(define-public nil #f)

(define-public (output-port-width . arg) 80)
(define-public (output-port-height . arg) 24)
(define (identity x) x)

;; slib 3a1 and up, straight from Template.scm
(define-public (call-with-open-ports . ports)
  (define proc (car ports))
  (cond ((procedure? proc) (set! ports (cdr ports)))
	(else (set! ports (reverse ports))
	      (set! proc (car ports))
	      (set! ports (reverse (cdr ports)))))
  (let ((ans (apply proc ports)))
    (for-each close-port ports)
    ans))

;; slib (version 3a1) requires open-file accept a symbol r, rb, w or wb for
;; MODES, so extend the guile core open-file accordingly.
;;
;; slib (version 3a1) also calls open-file with strings "rb" or "wb", not
;; sure if that's intentional, but in any case this extension continues to
;; accept strings to make that work.
;;
(define-public open-file
  (let ((guile-core-open-file open-file))
    (lambda (filename modes)
      (if (symbol? modes)
	  (set! modes (symbol->string modes)))
      (guile-core-open-file filename modes))))

;; returning #t/#f instead of throwing an error for failure
(define-public delete-file
  (let ((guile-core-delete-file delete-file))
    (lambda (filename)
      (catch 'system-error
	(lambda () (guile-core-delete-file filename) #t)
	(lambda args #f)))))

;; Nothing special to do for this, so straight from Template.scm.  Maybe
;; "sensible-browser" for a debian system would be worth trying too (and
;; would be good on a tty).
(define-public (browse-url url)
  (define (try cmd end) (zero? (system (string-append cmd url end))))
  (or (try "netscape-remote -remote 'openURL(" ")'")
      (try "netscape -remote 'openURL(" ")'")
      (try "netscape '" "'&")
      (try "netscape '" "'")))

;;; {Random numbers}
;;;
(define (make-random-state . args)
  (let ((seed (if (null? args) *random-state* (car args))))
    (cond ((string? seed))
	  ((number? seed) (set! seed (number->string seed)))
	  (else (let ()
		  (require 'object->string)
		  (set! seed (object->limited-string seed 50)))))
    (seed->random-state seed)))

;;; {rev2-procedures}
;;;

(define <?  <)
(define <=? <=)
(define =?  =)
(define >?  >)
(define >=? >=)

;;; {system}
;;;

;; If the program run is killed by a signal, the shell normally gives an
;; exit code of 128+signum.  If the shell itself is killed by a signal then
;; we do the same 128+signum here.
;;
;; "stop-sig" shouldn't arise here, since system shouldn't be calling
;; waitpid with WUNTRACED, but allow for it anyway, just in case.
;;
(if (defined? 'system)
    (define-public system
      (let ((guile-core-system system))
	(lambda (str)
	  (let ((st (guile-core-system str)))
	    (or (status:exit-val st)
		(+ 128 (or (status:term-sig st)
			   (status:stop-sig st)))))))))

;;; {Time}
;;;

(define-public difftime -)
(define-public offset-time +)


(define %system-define define)

(define define
  (procedure->memoizing-macro
   (lambda (exp env)
     (if (= (length env) 1)
	 `(define-public ,@(cdr exp))
	 `(%system-define ,@(cdr exp))))))

;;; Hack to make syncase macros work in the slib module
(if (nested-ref the-root-module '(app modules ice-9 syncase))
    (set-object-property! (module-local-variable (current-module) 'define)
			  '*sc-expander*
			  '(define)))

(define (software-type)
  "Return a symbol describing the current platform's operating system.
This may be one of AIX, VMS, UNIX, COHERENT, WINDOWS, MS-DOS, OS/2,
THINKC, AMIGA, ATARIST, MACH, or ACORN.

Note that most varieties of Unix are considered to be simply \"UNIX\".
That is because when a program depends on features that are not present
on every operating system, it is usually better to test for the presence
or absence of that specific feature.  The return value of
@code{software-type} should only be used for this purpose when there is
no other easy or unambiguous way of detecting such features."
 'UNIX)

(slib:load (in-vicinity (library-vicinity) "require.scm"))

(define require require:require)

;; {Extensions to the require system so that the user can add new
;;  require modules easily.}

(define *vicinity-table*
  (list
   (cons 'implementation (implementation-vicinity))
   (cons 'library (library-vicinity))))

(define (install-require-vicinity name vicinity)
  (let ((entry (assq name *vicinity-table*)))
    (if entry
	(set-cdr! entry vicinity)
	(set! *vicinity-table*
	      (acons name vicinity *vicinity-table*)))))

(define (install-require-module name vicinity-name file-name)
  (if (not *catalog*)	     ;Fix which loads catalog in slib
      (catalog:get 'random)) ;(doesn't load the feature 'random)
  (let ((entry (assq name *catalog*))
	(vicinity (cdr (assq vicinity-name *vicinity-table*))))
    (let ((path-name (in-vicinity vicinity file-name)))
      (if entry
	  (set-cdr! entry path-name)
	  (set! *catalog*
		(acons name path-name *catalog*))))))

(define (make-exchanger obj)
  (lambda (rep) (let ((old obj)) (set! obj rep) old)))
