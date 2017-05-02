#lang info

(define collection "contract-profile")
(define deps '(("base" #:version "6.3")
               "math-lib"
               ("profile-lib" #:version "1.1")))
(define build-deps '("racket-doc"
                     "scribble-lib"
                     "rackunit-lib"))

(define pkg-desc "Profiling tool for contracts")

(define pkg-authors '(stamourv))

(define raco-commands
  '(("contract-profile"
     contract-profile/raco
     "profile overhead from contracts"
     #f)))
