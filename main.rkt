#lang racket/base

(module+ test
  (require rackunit))

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco doc <<name>>
;;
;; For your convenience, we have included a LICENSE.txt file, which links to
;; the GNU Lesser General Public License.
;; If you would prefer to use a different license, replace LICENSE.txt with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html

;; Code here

(require "fanfy.rkt")

(module+ test
  ;; Tests to be run with raco test
  (let ((mourn-the-dead-details (get-ff-details 11738243)))
    (check-equal? (car mourn-the-dead-details) "RoeRemedy")
    (check-equal? (cadr mourn-the-dead-details) "Mourn the dead")
    (check-equal? (map car (caddr mourn-the-dead-details))
                  '("Aftermath"
                    "Salt"
                    "In between"
                    "New day"
                    "Escape"
                    "Survivors")))
  )

(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
