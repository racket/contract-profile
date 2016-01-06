#lang scribble/doc

@(require scribble/manual
          scribble/eval
          (for-label racket/base racket/contract))
@(define contract-profile-eval
  (make-base-eval
    '(begin (require contract-profile
                     racket/contract
                     (only-in racket/file file->string)
                     racket/list))))

@title[#:tag "contract-profiling"]{Contract Profiling}

@defmodule[contract-profile]

This module provides experimental support for contract profiling.

@defform[(contract-profile option ... body ...)
         #:grammar [(option (code:line #:module-graph-file module-graph-file)
                            (code:line #:boundary-view-file boundary-view-file)
                            (code:line #:boundary-view-key-file boundary-view-key-file))]]{

Produces several reports about the performance costs related to contract
checking in @racket[body]. Some of these reports are printed to files.
Each destination file can be controlled using the corresponding optional
keyword argument. An argument of @racket[#f] disables that portion of the
output.

@itemlist[
@item{
  @emph{Cost Breakdown}:
  Displays the proportion of @racket[body]'s running time that was spent
  checking contracts and breaks that time down by contract, then by contracted
  function and finally by caller for each contracted function.

  This report is printed on standard output.
}
@item{
  @emph{Module Graph View} (defaults to @tt{tmp-contract-profile-module-graph.dot.pdf}):
  Shows a graph of modules (nodes) and the contract boundaries (edges) between
  them that were crossed while running @racket[body].

  The weight on each contract boundary edge corresponds to the time spent
  checking contracts applied at this boundary.
  Modules written in Typed Racket are displayed in green and untyped modules
  are displayed in red.

  These graphs are rendered using Graphviz. The Graphviz source is available in
  (by default) @tt{tmp-contract-profile-module-graph.dot}. The rendered version
  of the graph is only available if the contract profiler can locate a Graphviz
  install.
}
@item{
  @emph{Boundary View} (defaults to @tt{tmp-contract-profile-boundary-graph.dot.pdf}):
  Shows a detailed view of how contract checking costs are spread out across
  contracted functions, broken down by contract boundary.

  Contracted functions are shown as rectangular nodes colored according to the
  cost of checking their contracts.
  Edges represent function calls that cross contract boundaries and cause
  contracts to be applied. These edges are extracted from profiling
  information, and therefore represent incomplete information. Because of this,
  the contract profiler sometimes cannot determine the callers of contracted
  functions.
  Non-contracted functions that call contracted functions across a boundary are
  shown as gray ellipsoid nodes. @; TODO this explanation is not great
  Nodes are clustered by module. @; TODO explain more


  Each node reports its (non-contract-related) self time. In addition,
  contracted function nodes list the contract boundaries the function
  participates in, as well as the cost of checking the contracts associated
  with each boundary. For space reasons, full contracts are not displayed on
  the graph and are instead numbered. The mapping from numbers to contracts is
  found in (by default) @tt{tmp-contract-profile-contract-key.txt}.

  These graphs are rendered using Graphviz. The Graphviz source is available in
  (by default) @tt{tmp-contract-profile-boundary-graph.dot}. The rendered
  version of the graph is only available if the contract profiler can locate a
  Graphviz install.
}
]

}

@defproc[(contract-profile-thunk
          [thunk (-> any)]
          [#:module-graph-file module-graph-file (or/c path-string #f) #f]
          [#:boundary-view-file boundary-view-file (or/c path-string #f) #f]
          [#:boundary-view-key-file boundary-view-key-file (or/c path-string #f) #f]) any]{
  Like @racket[contract-profile], but as a function which takes a thunk to
  profile as argument.
}


@examples[#:eval contract-profile-eval
  (define/contract (sum* numbers)
    (-> (listof integer?) integer?)
    (for/fold ([total 0])
              ([n (in-list numbers)])
      (+ total n)))

  (contract-profile #:module-graph-file #f
                    #:boundary-view-file #f
                    #:boundary-view-key-file #f
                    (sum* (range (expt 10 6))))
]

The example shows that a large proportion of the call to @racket[sum*]
with a list of 1 million integers is spent validating the input list.


Note that the contract profiler is unlikely to detect fast-running contracts
that trigger other, slower contract checks.
In the following example, there is a higher chance that the profiler
samples a @racket[(listof integer?)] contract than the underlying
@racket[(vectorof list?)] contract.

@examples[#:eval contract-profile-eval
  (define/contract (vector-max* vec-of-numbers)
    (-> (vectorof list?) integer?)
    (for/fold ([total 0])
              ([numbers (in-vector vec-of-numbers)])
      (+ total (sum* numbers))))

  (contract-profile #:module-graph-file #f
                    #:boundary-view-file #f
                    #:boundary-view-key-file #f
                    (vector-max* (make-vector 10 (range (expt 10 6)))))
]

Also note that old results files are overwritten by future calls to the
contract profiler.
