# Molecular App — Backend API Contract

## Authentication

Protected endpoints require:

```http
Authorization: Bearer <accessToken>
```

JWT expires after **1 day**.

**Invalid/expired JWT → `401 Unauthorized`**
Frontend: delete JWT → clear user state → redirect to Login.

---

## Endpoints

### `POST /auth/register`

**Request**

```json
{
  "firstName": "Zakaria",
  "lastName": "El Baghazaoui",
  "email": "zakaria@example.com",
  "password": "password"
}
```

**Success — `201`**

```json
{
  "accessToken": "<JWT>"
}
```

**Errors**

| Status | Message                      | Frontend action                       |
| ------ | ---------------------------- | ------------------------------------- |
| `409`  | `"Email already registered"` | Tell user email is already registered |
| `500`  | `"Internal server error"`    | Show generic error                    |

---

### `POST /auth/login`

**Request**

```json
{
  "email": "zakaria@example.com",
  "password": "password"
}
```

**Success — `200`**

```json
{
  "accessToken": "<JWT>",
  "user": {
    "id": 1,
    "firstName": "Zakaria",
    "lastName": "El Baghazaoui",
    "email": "zakaria@example.com",
    "favorites": ["BNZ", "0EA"]
  }
}
```

**Errors**

| Status | Message                   | Frontend action          |
| ------ | ------------------------- | ------------------------ |
| `401`  | `"Invalid credentials"`   | Show invalid credentials |
| `500`  | `"Internal server error"` | Show generic error       |

---

### `GET /molecules/:moleculeId`

Fetches and parses the molecule from RCSB.

**Success — `200`**

```json
{
  "id": "BNZ",
  "name": "<molecule name>",
  "type": "<molecule type>",
  "formula": "<chemical formula>",
  "atoms": [
    {
      "id": "C1",
      "element": "C",
      "x": 0.0,
      "y": 1.234,
      "z": 2.345
    }
  ],
  "bonds": [
    {
      "atom1": "C1",
      "atom2": "C2",
      "order": "DOUB"
    }
  ]
}
```

Bond orders: `SING`, `DOUB`, `TRIP`.

**Errors**

| Status | Message                                      | Frontend action                             |
| ------ | -------------------------------------------- | ------------------------------------------- |
| `502`  | `"Unable to communicate with RCSB"`          | Show temporary error + allow retry          |
| `502`  | `"RCSB request failed with status <status>"` | Show molecule retrieval error + allow retry |
| `500`  | `"Internal server error"`                    | Show generic error                          |

---

### `POST /favorites/:moleculeId`

Requires JWT.

**Success — `201`**

```json
{
  "id": 12,
  "userId": 1,
  "moleculeId": "BNZ",
  "createdAt": "2026-10-03T12:00:00.000Z"
}
```

**Errors**

| Status | Meaning               | Frontend action                           |
| ------ | --------------------- | ----------------------------------------- |
| `401`  | Invalid/expired JWT   | Delete JWT → Login                        |
| `500`  | Database/server error | Keep previous favorite state + show error |

---

### `DELETE /favorites/:moleculeId`

Requires JWT.

**Success — `200`**

Returns the deleted favorite.

**Errors**

| Status | Meaning                 | Frontend action                           |
| ------ | ----------------------- | ----------------------------------------- |
| `401`  | Invalid/expired JWT     | Delete JWT → Login                        |
| `500`  | Database/server error   | Keep previous favorite state + show error |

---

## Frontend Rules

* **Only update favorite state after a successful response.**
* `401` on a protected endpoint → **delete JWT and return to Login**.
* `500` on favorite operations → **do not fake success**; keep the previous state.
* `502` from molecules → RCSB/backend problem; **allow retry**.
* Login already returns the user's `favorites`, so there is currently **no `GET /favorites` endpoint**.
* Logout = delete JWT locally and return to Login.
