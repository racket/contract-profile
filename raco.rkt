#lang racket/base

(require racket/cmdline
         raco/command-name
         "main.rkt")

;; raco contract-profile
;; profile the main submodule (if there is one), or the top-level module

(define module-graph-file #f)
(define boundary-view-file #f)
(define boundary-view-key-file #f)
(define file
  (command-line #:program (short-program+command-name)
                #:once-each
                [("--module-graph-file") file
                 "Output module view to <file>"
                 (set! module-graph-file file)]
                [("--boundary-view-file") file
                 "Output boundary view to <file>"
                 (set! boundary-view-file file)]
                [("--boundary-view-key-file") file
                 "Output boundary view key to <file>"
                 (set! boundary-view-key-file file)]
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
 #:module-graph-file module-graph-file
 #:boundary-view-file boundary-view-file
 #:boundary-view-key-file boundary-view-key-file
 (dynamic-require target #f))
