 ;; Basic Staking Platform
;; Two-function staking example in Clarity

;; Track staked balances
(define-map stakes principal uint)

;; Track total staked STX
(define-data-var total-staked uint u0)

;; Error constants
(define-constant err-invalid-amount (err u100))
(define-constant err-no-stake (err u101))
(define-constant err-transfer-failed (err u102))

;; Stake STX
(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set stakes tx-sender
             (+ (default-to u0 (map-get? stakes tx-sender)) amount))
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)))

;; Unstake STX
(define-public (unstake (amount uint))
  (let ((current-stake (default-to u0 (map-get? stakes tx-sender))))
    (begin
      (asserts! (> amount u0) err-invalid-amount)
      (asserts! (>= current-stake amount) err-no-stake)
      (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
      (map-set stakes tx-sender (- current-stake amount))
      (var-set total-staked (- (var-get total-staked) amount))
      (ok true))))
