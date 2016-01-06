#lang racket/base

(require racket/port
         contract-profile
         (only-in contract-profile/utils dry-run? make-shortener))

(module+ test
  (require rackunit)

  ;; reported by Greg Hendershott
  (define res
    (with-output-to-string
      (lambda ()
        (check-true (contract-profile #:module-graph-file #f
                                      #:boundary-view-file #f
                                      #:boundary-view-key-file #f
                                      #t)))))
  (check-regexp-match #rx"^Running time is 0% contracts" res)

  ;; test options for `contract-profile-thunk`
  (let ([res
         (with-output-to-string
           (lambda ()
             (check-false
               (contract-profile-thunk
                 #:module-graph-file #f
                 #:boundary-view-file #f
                 #:boundary-view-key-file #f
                 (lambda () (string? 4))))))])
    (check-regexp-match #rx"0% contracts" res))

  (dry-run? #t) ; don't output to files

  (require math)
  (let ()
    (define dim 200)
    (define big1 (build-matrix dim dim (lambda (i j) (random))))
    (define big2 (build-matrix dim dim (lambda (i j) (random))))
    (define (main) (matrix* big1 big2))
    (check-true (matrix? (contract-profile (main)))))

  ;; test path shortening
  (define paths '("a/b/c.rkt" "a/b/d.rkt" ("a/b/e.rkt" f) (something else)))
  (define shortener (make-shortener paths))
  (check-equal? (map shortener paths)
                (list (build-path "c.rkt")
                      (build-path "d.rkt")
                      (list (build-path "e.rkt") 'f)
                      '(something else)))
  )
