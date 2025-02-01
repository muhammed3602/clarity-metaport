;; MetaPort - Decentralized Metaverse Navigation System

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-exists (err u101))
(define-constant err-not-found (err u102))
(define-constant err-unauthorized (err u103))

;; Data structures
(define-map portals
  { portal-id: uint }
  {
    owner: principal,
    destination: (string-utf8 256),
    metadata: (string-utf8 1024),
    active: bool
  }
)

(define-map portal-owners
  { owner: principal }
  { portal-count: uint }
)

;; Data variables
(define-data-var portal-count uint u0)

;; Public functions
(define-public (register-portal (destination (string-utf8 256)) (metadata (string-utf8 1024)))
  (let
    (
      (portal-id (+ (var-get portal-count) u1))
      (owner tx-sender)
    )
    (asserts! (is-valid-destination destination) (err-already-exists))
    (try! (create-portal portal-id owner destination metadata))
    (var-set portal-count portal-id)
    (ok portal-id)
  )
)

(define-public (transfer-portal (portal-id uint) (new-owner principal))
  (let
    ((portal (get-portal portal-id)))
    (asserts! (is-eq (get owner portal) tx-sender) err-unauthorized)
    (try! (update-portal-owner portal-id new-owner))
    (ok true)
  )
)

(define-public (update-metadata (portal-id uint) (new-metadata (string-utf8 1024)))
  (let
    ((portal (get-portal portal-id)))
    (asserts! (is-eq (get owner portal) tx-sender) err-unauthorized)
    (try! (update-portal-metadata portal-id new-metadata))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-portal (portal-id uint))
  (default-to
    {
      owner: contract-owner,
      destination: u"",
      metadata: u"",
      active: false
    }
    (map-get? portals { portal-id: portal-id })
  )
)

(define-read-only (get-owner-portals (owner principal))
  (default-to
    { portal-count: u0 }
    (map-get? portal-owners { owner: owner })
  )
)
