;; Title: Decentralized Lending Protocol
;; Summary: A secure lending protocol enabling sBTC-collateralized loans with liquidation mechanisms
;; Description: This contract implements a lending protocol where users can:
;;   - Deposit sBTC as collateral
;;   - Borrow against their collateral
;;   - Repay loans
;;   - Participate in liquidations of under-collateralized positions
;; The protocol maintains a minimum collateralization ratio and includes
;; safety mechanisms like pause functionality and liquidation thresholds.

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))
(define-constant ERR-LIQUIDATION-FAILED (err u106))

;; Protocol Parameters
(define-constant MIN-COLLATERAL-RATIO u150)  ;; 150% minimum collateralization ratio

;; Protocol State
(define-data-var contract-owner principal tx-sender)
(define-data-var protocol-paused bool false)
(define-data-var total-deposits uint u0)
(define-data-var total-borrows uint u0)
(define-data-var interest-rate uint u500)  ;; 5% APR in basis points
(define-data-var liquidation-threshold uint u8000)  ;; 80% threshold in basis points

;; Storage Maps
(define-map user-deposits 
    { user: principal } 
    { amount: uint }
)

(define-map user-borrows 
    { user: principal } 
    { 
        amount: uint, 
        collateral: uint 
    }
)

(define-map liquidator-rewards 
    { liquidator: principal } 
    { amount: uint }
)

;; SIP-010 Fungible Token Interface
(define-trait sip-010-trait
    (
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (get-balance (principal) (response uint uint))
    )
)

;; Authorization
(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner))
)

;; Core Protocol Functions

;; Initialize the protocol with the specified token contract
(define-public (initialize (token-contract <sip-010-trait>))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (ok true)
    )
)

;; Deposit sBTC as collateral
(define-public (deposit-collateral (token-contract <sip-010-trait>) (amount uint))
    (let
        (
            (sender tx-sender)
            (current-deposit (default-to { amount: u0 } (map-get? user-deposits { user: sender })))
        )
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (not (var-get protocol-paused)) ERR-NOT-INITIALIZED)
        
        (match (contract-call? token-contract transfer amount sender (as-contract tx-sender) none)
            success
                (begin
                    (map-set user-deposits
                        { user: sender }
                        { amount: (+ amount (get amount current-deposit)) }
                    )
                    (var-set total-deposits (+ (var-get total-deposits) amount))
                    (ok true)
                )
            error (err ERR-INSUFFICIENT-BALANCE)
        )
    )
)

;; Borrow against deposited collateral
(define-public (borrow (token-contract <sip-010-trait>) (amount uint))
    (let
        (
            (sender tx-sender)
            (user-deposit (default-to { amount: u0 } (map-get? user-deposits { user: sender })))
            (user-borrow (default-to { amount: u0, collateral: u0 } (map-get? user-borrows { user: sender })))
            (collateral-value (get amount user-deposit))
            (borrow-value (+ amount (get amount user-borrow)))
        )
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (not (var-get protocol-paused)) ERR-NOT-INITIALIZED)
        (asserts! (is-collateral-sufficient collateral-value borrow-value) ERR-INSUFFICIENT-COLLATERAL)
        
        (map-set user-borrows
            { user: sender }
            { amount: borrow-value, collateral: collateral-value }
        )
        (var-set total-borrows (+ (var-get total-borrows) amount))
        (ok true)
    )
)

;; Repay borrowed amount
(define-public (repay (token-contract <sip-010-trait>) (amount uint))
    (let
        (
            (sender tx-sender)
            (user-borrow (default-to { amount: u0, collateral: u0 } (map-get? user-borrows { user: sender })))
            (borrow-amount (get amount user-borrow))
        )
        (asserts! (>= borrow-amount amount) ERR-INVALID-AMOUNT)
        
        (match (contract-call? token-contract transfer amount sender (as-contract tx-sender) none)
            success
                (begin
                    (map-set user-borrows
                        { user: sender }
                        { amount: (- borrow-amount amount), collateral: (get collateral user-borrow) }
                    )
                    (var-set total-borrows (- (var-get total-borrows) amount))
                    (ok true)
                )
            error (err ERR-INSUFFICIENT-BALANCE)
        )
    )
)