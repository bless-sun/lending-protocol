;; Mock SIP-010 token for testing
(define-fungible-token mock-token)

(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INSUFFICIENT-BALANCE (err u402))
(define-constant ERR-INVALID-AMOUNT (err u403))
(define-constant ERR-INVALID-RECIPIENT (err u404))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (>= (ft-get-balance mock-token sender) amount) ERR-INSUFFICIENT-BALANCE)
    (asserts! (not (is-eq recipient sender)) ERR-INVALID-RECIPIENT)
    (asserts! (not (is-eq recipient (as-contract tx-sender))) ERR-INVALID-RECIPIENT)
    (try! (ft-transfer? mock-token amount sender recipient))
    (ok true)))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (is-eq recipient contract-owner)) ERR-INVALID-RECIPIENT)
    (asserts! (not (is-eq recipient (as-contract tx-sender))) ERR-INVALID-RECIPIENT)
    (try! (ft-mint? mock-token amount recipient))
    (ok true)))

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance mock-token user)))

(define-public (approve (spender principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (not (is-eq spender tx-sender)) ERR-INVALID-RECIPIENT)
    (ok true)))