#lang racket/base

(require racket/cmdline
         raco/command-name
         "main.rkt")

;; raco contract-profile
;; profile the main submodule (if there is one), or the top-level module

(define file
  (command-line #:program (short-program+command-name)
                #:args (filename)
                filename))

;; check if there's a main submodule
(define file-path `(file ,file))
(define main-path `(submod ,file-path main))
(dynamic-require file-path (void)) ; visit the module, but don't run it
(define target
  (if (module-declared? main-path #f)
      main-path
      file-path))

(contract-profile
 (dynamic-require target #f))
