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