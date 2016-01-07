#lang info

(define collection "contract-profile")
(define deps '("base"
               "profile-lib"))
(define build-deps '("racket-doc"
                     "scribble-lib"
                     "rackunit-lib"
                     "math-lib"))

(define pkg-desc "Profiling tool for contracts")

(define pkg-authors '(stamourv))

(define raco-commands
  '(("contract-profile"
     contract-profile/raco
     "profile overhead from contracts"
     #f)))
