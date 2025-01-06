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
