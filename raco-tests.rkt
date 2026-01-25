#lang racket/base

(require rackunit)
(require racket/system
        racket/port
        math/statistics)

(define (get-total-time profiling-command)
  (string->number (car (regexp-match #rx"[0-9]+" (car (regexp-match #rx"/[0-9]+ ms" (with-output-to-string (lambda () (system profiling-command)))))))))

(for ([i (in-range 5)])
   (define whole-time (get-total-time "racket raco.rkt test-inputs/main.rkt"))
   (define instantiation-only-time (get-total-time "racket raco.rkt --instantiation-only test-inputs/main.rkt"))
   (check-true (> whole-time instantiation-only-time)))