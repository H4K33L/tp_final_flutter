# SnapThème — Conception

## 1. Cycle de vie d'une room

État de la room (`rooms/{roomId}.status`) :

```
waiting   → lobby, joueurs rejoignent, host attend que tout le monde soit "ready"
starting  → host a lancé, thème de la manche 1 en cours de sélection
playing   → manche en cours, joueurs prennent/uploadent leur photo (endsAt actif)
voting    → uploads clos (ou timer écoulé), joueurs votent
results   → scores de la manche affichés, brève pause avant la manche suivante
playing/voting/results se répètent → une manche par cycle
finished  → nombre de manches atteint, classement final affiché
```

Transitions pilotées uniquement par le **host** (ou par un déclencheur logique côté
client qui détecte `endsAt` dépassé — voir §4). Aucun joueur non-host ne peut modifier
`status`.

## 2. Modélisation d'une manche — règle retenue

Deux variantes étaient possibles :
- **A. Rotation du photographe** : un seul joueur photographie par manche, les autres
  votent seulement.
- **B. Tous concernés** : chaque manche, **tous les joueurs actifs** (non-spectateurs)
  reçoivent le même thème et soumettent chacun une photo ; le rôle qui tourne est
  celui du **"maître du thème"** (le joueur qui choisit ou valide le thème de la
  manche).

**Choix retenu : B.** Justification : avec 3 à 6 joueurs, la variante A laisse la
majorité des joueurs inactifs pendant la phase de capture (ennuyeux, peu de contenu
à voter). La variante B maximise l'engagement (tout le monde photographie à chaque
manche) et donne un vote plus riche (3 à 6 photos par manche au lieu d'une seule).
Le rôle de "maître du thème" tourne à chaque manche selon l'ordre d'arrivée dans
`players` (`themeMasterIndex = roundNumber % playerCount`), ce qui garantit une
répartition équitable sans état supplémentaire à synchroniser.

Un round est donc représenté par :
```
rounds/{roundNumber}
  theme: string
  themeMasterId: string        // joueur qui a choisi/validé le thème
  status: "capturing" | "voting" | "closed"
  startedAt: Timestamp
  endsAt: Timestamp             // fin de la fenêtre de capture (60s)
  votingEndsAt: Timestamp       // fin de la fenêtre de vote (optionnel, ex: 30s)
```

## 3. Où sont stockés les votes (anti-double-vote)

`votes` est une **sous-collection du round**, avec un **ID de document déterministe** :

```
rooms/{roomId}/rounds/{roundNumber}/votes/{voterId}
  votedForPlayerId: string
  votedAt: Timestamp (serverTimestamp)
```

Comme l'ID du document *est* l'UID du votant, un joueur ne peut matériellement écrire
qu'un seul document de vote par manche. La règle de sécurité Firestore interdit toute
**mise à jour** (`update`) de ce document une fois créé — seule la **création**
(`create`) est autorisée, et uniquement si `request.auth.uid == voterId` et
`votedForPlayerId != voterId` (on ne peut pas voter pour soi-même). Résultat : un vote
= un document = immuable = pas de double vote possible, sans transaction nécessaire.

## 4. Synchronisation du timer 60s

**Piège évité** : ne jamais démarrer un `Timer()` local indépendamment sur chaque
device (dérive garantie).

**Mécanisme retenu** :
1. Le host (ou la première personne qui déclenche le passage en `playing`) écrit
   `rounds/{n}.endsAt` en une seule fois, calculé côté client à partir d'une
   estimation de l'heure serveur : on effectue d'abord un petit "ping" d'horloge
   (écriture d'un champ avec `FieldValue.serverTimestamp()` puis lecture immédiate
   du delta avec `DateTime.now()`) pour connaître le décalage horloge locale/serveur,
   puis on écrit `endsAt = serverNow + Duration(seconds: 60)`.
2. Tous les clients (y compris le host) calculent leur compte à rebours affiché comme
   `endsAt - (DateTime.now() - offsetHorlogeLocal)`, jamais comme `60 - tempsEcoulLocal`.
3. Le passage automatique `playing → voting` est déclenché par **n'importe quel
   client** qui détecte `DateTime.now(corrigé) >= endsAt` et effectue une écriture
   idempotente du statut (protégée par une règle "on ne peut passer de playing à
   voting que si maintenant >= endsAt", vérifiable côté règles de sécurité avec
   `request.time >= resource.data.endsAt`). Ainsi, même si le host quitte l'app,
   la manche progresse quand même.

Ce champ `endsAt` unique, écrit une fois, est la seule source de vérité temporelle —
aucun `Timer` local ne fait autorité sur l'état du jeu, il ne sert qu'à l'affichage.

## 5. Permissions (host / joueur / spectateur)

| Action | Host | Joueur actif | Spectateur |
|---|---|---|---|
| Créer/configurer la room | ✅ | ❌ | ❌ |
| Démarrer la partie (waiting→starting) | ✅ | ❌ | ❌ |
| Choisir/valider le thème (si "maître du thème") | ✅ si c'est son tour | ✅ si c'est son tour | ❌ |
| Soumettre une photo | ✅ | ✅ | ❌ |
| Voter | ✅ | ✅ | ✅ |
| Forcer le passage à la manche suivante (edge case) | ✅ | ❌ | ❌ |

Ces droits sont stockés dans `players/{uid}` (`isHost`, `canCapture`, `isSpectator`)
et vérifiés côté **règles de sécurité Firestore** (jamais uniquement côté client) :
toute écriture d'une soumission vérifie que `players/{uid}.canCapture == true` et
que `round.status == "capturing"`.

## 6. Schéma Firestore

```
rooms/{roomId}
  code: string                 // code court partageable, ex: "AB3F"
  hostId: string
  status: "waiting"|"starting"|"playing"|"voting"|"results"|"finished"
  maxPlayers: number            // 3 à 6
  totalRounds: number
  currentRound: number
  createdAt: Timestamp

  players/{uid}
    displayName: string
    joinedAt: Timestamp
    isHost: bool
    isReady: bool
    canCapture: bool            // false si permission caméra refusée → spectateur
    isSpectator: bool
    totalScore: number          // dénormalisé pour affichage rapide du classement

  rounds/{roundNumber}
    theme: string
    themeMasterId: string
    status: "capturing"|"voting"|"closed"
    startedAt: Timestamp
    endsAt: Timestamp
    votingEndsAt: Timestamp

    submissions/{playerId}
      photoUrl: string
      storagePath: string       // utile pour suppression/modération
      submittedAt: Timestamp

    votes/{voterId}
      votedForPlayerId: string
      votedAt: Timestamp

    results/{playerId}          // calculé à la clôture du vote (Cloud Function ou client agrégateur)
      voteCount: number
      pointsEarned: number
```

Stockage associé : `storage/rooms/{roomId}/rounds/{roundNumber}/{playerId}.jpg`.

### Justification collection par collection
- **`players`** en sous-collection (et non tableau dans `rooms`) : chaque joueur écrit
  son propre statut (`isReady`, `canCapture`) indépendamment, sans toucher au document
  des autres → pas de conflit d'écriture concurrente, règles de sécurité simples
  (`request.auth.uid == playerId`).
- **`rounds`** séparé de `rooms` : l'historique des manches grossit au fil de la partie ;
  l'isoler évite de faire grossir indéfiniment le document `room` (limite 1 Mo) et
  permet de ne lire/écouter que la manche courante plutôt que tout l'historique.
- **`submissions`** en sous-collection du round : chaque joueur écrit son propre
  document, écriture parallèle sans contention, et la grille de vote se construit par
  une simple requête `rounds/{n}/submissions`.
- **`votes`** séparé des `submissions` : sépare clairement "ce que j'ai produit" de
  "ce que j'ai choisi", permet des règles de sécurité distinctes (lecture des votes
  bloquée tant que `round.status == "voting"`, pour ne pas influencer les votants —
  *voir remarque ci-dessous*), et rend le comptage des votes trivial.
- **`results`** distinct de `votes` : évite de recompter les votes à chaque affichage ;
  écrit une seule fois à la clôture de la manche (agrégation), consommé en lecture
  seule par tous les clients pour l'écran de classement.

> Remarque : pour un vote "à l'aveugle", une règle de sécurité peut interdire la
> lecture de `votes/*` tant que `round.status != "closed"` — seul le compteur global
> (si affiché en direct) transiterait via un champ dénormalisé, pas via la lecture
> directe des votes individuels.

## 7. Question de compréhension : pourquoi pas un seul document `room` géant ?

Avec 6 joueurs qui écrivent en même temps (photo soumise, vote, statut "ready"...),
tout faire tenir dans un unique document `rooms/{roomId}` pose plusieurs problèmes :

1. **Contention d'écriture** : Firestore recommande de ne pas dépasser ~1
   écriture/seconde sur un même document en usage soutenu. Si 6 joueurs modifient le
   même document simultanément (ex: tous soumettent leur URL de photo en même temps
   en fin de timer), les écritures se sérialisent et les transactions échouent en
   cascade (`ABORTED`), obligeant à retry côté client — source de bugs et de latence.
2. **Re-render / bande passante inutiles** : un `snapshot listener` sur un document
   entier notifie **tous les champs** à chaque écriture, même si un seul champ a
   changé. Si tout est dans `room`, la photo soumise par le joueur A déclenche une
   mise à jour reçue par tous les autres clients, qui retélé chargent tout le
   document (players, rounds, votes...) au lieu de la seule sous-collection
   pertinente.
3. **Limite de taille** : un document Firestore est limité à 1 Mo. Un historique de
   plusieurs manches avec soumissions, votes et résultats de 6 joueurs finirait par
   s'en approcher si tout est imbriqué dans un seul document (surtout avec des
   tableaux qui grossissent sans jamais être purgés).
4. **Règles de sécurité peu granulaires** : il est difficile d'exprimer "le joueur X
   ne peut modifier que son propre champ dans un tableau imbriqué" en règles
   Firestore. Avec des sous-collections dont l'ID de document = UID du joueur,
   la règle `request.auth.uid == playerId` suffit.
5. **Requêtes impossibles sur les champs imbriqués d'un tableau** : compter les votes,
   filtrer les joueurs prêts, etc. sont triviaux en sous-collection (`where`, agrégats)
   mais nécessitent de tout retélécharger et filtrer côté client si tout est un
   tableau dans un seul document.

Les sous-collections permettent donc des écritures **isolées par joueur**, des
**listeners ciblés** (on écoute `submissions` pendant la capture, `votes` pendant le
vote, pas tout le document), et des **règles de sécurité précises**.
