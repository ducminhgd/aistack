# RESTful API Best Practices

## Resource Naming

1. **Use nouns, not verbs**: Resources are things, not actions.
   - Good: `GET /users`, `POST /orders`
   - Bad: `GET /getUsers`, `POST /createOrder`
2. **Plural resource names**: `/users`, `/products`, `/orders` — not `/user`, `/product`.
3. **Lowercase and hyphens**: Use `kebab-case` for multi-word resource names: `/product-categories`, not `/productCategories` or `/product_categories`.
4. **Hierarchical relationships**: Express sub-resources with nesting, limited to 2–3 levels:
   - Good: `GET /users/{userId}/orders/{orderId}`
   - Avoid: `GET /users/{userId}/orders/{orderId}/items/{itemId}/reviews`
5. **Query parameters for filtering, sorting, pagination** — not path segments:
   - `GET /products?category=books&sort=price&order=asc&page=2&limit=20`

## HTTP Methods

6. **Use HTTP methods semantically**:

   | Method | Semantics | Body | Idempotent | Safe |
   |--------|-----------|------|------------|------|
   | `GET` | Retrieve | No | Yes | Yes |
   | `POST` | Create / trigger action | Yes | No | No |
   | `PUT` | Full replace | Yes | Yes | No |
   | `PATCH` | Partial update | Yes | No | No |
   | `DELETE` | Remove | Optional | Yes | No |

7. **`POST` for non-CRUD actions**: Use sub-resources or action segments for actions that don't map to CRUD:
   - `POST /orders/{orderId}/cancel`
   - `POST /users/{userId}/password-reset`

## HTTP Status Codes

8. **Use precise status codes** — not just `200` and `500`:

   | Code | When to use |
   |------|-------------|
   | `200 OK` | Successful GET, PUT, PATCH, DELETE with body |
   | `201 Created` | Successful POST that created a resource; include `Location` header |
   | `202 Accepted` | Request accepted for async processing |
   | `204 No Content` | Successful DELETE or action with no response body |
   | `400 Bad Request` | Client sent malformed or invalid data |
   | `401 Unauthorized` | Authentication required or invalid credentials |
   | `403 Forbidden` | Authenticated but not authorized |
   | `404 Not Found` | Resource does not exist |
   | `409 Conflict` | State conflict (duplicate, version mismatch) |
   | `422 Unprocessable Entity` | Semantically invalid input (validation errors) |
   | `429 Too Many Requests` | Rate limit exceeded |
   | `500 Internal Server Error` | Unexpected server failure |
   | `503 Service Unavailable` | Upstream dependency down or overloaded |

9. **Never return `200` with an error in the body**. The HTTP status code IS the status.

## Request and Response Design

10. **Use JSON** as the default content type. Set `Content-Type: application/json` and `Accept: application/json`.
11. **`camelCase` for JSON field names** (or `snake_case` — pick one and be consistent across the entire API).
12. **Wrap collections in an object** to allow adding metadata later:
    ```json
    {
      "data": [...],
      "meta": { "total": 100, "page": 2, "limit": 20 }
    }
    ```
13. **Consistent error response format**:
    ```json
    {
      "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid request body",
        "details": [
          { "field": "email", "message": "must be a valid email address" }
        ]
      }
    }
    ```
14. **Never expose internal details in errors**: No stack traces, SQL errors, or internal paths in production responses.
15. **Use ISO 8601 for dates and times**: `"2024-06-15T08:30:00Z"`. Always return UTC; let the client localize.
16. **Use strings for IDs** in JSON responses, even if the backend uses integers, to avoid JavaScript `Number` precision loss for large IDs.

## Versioning

17. **Version your API from day one**: Use URI versioning as the default — `/v1/`, `/v2/`.
18. **Never make breaking changes within a version**: Adding optional fields is safe; removing or renaming fields is a breaking change.
19. **Breaking changes** = new major version. Maintain the previous version for a documented deprecation period.
20. **Deprecation headers**: Signal deprecated endpoints with `Deprecation: true` and `Sunset: <date>` headers.

## Authentication and Authorization

21. **Use OAuth 2.0 / OpenID Connect** for user-facing APIs. Use API keys (passed in `Authorization: Bearer <key>`) for service-to-service.
22. **Never pass credentials in query parameters**: They appear in server logs and browser history.
23. **Validate authorization on every request**: Do not rely on the client to omit unauthorized data.
24. **Principle of least privilege**: Scope tokens to the minimum permissions required.

## Pagination

25. **Always paginate list endpoints**. Never return unbounded collections.
26. **Cursor-based pagination** for large or frequently changing datasets. **Offset pagination** for simple, stable datasets.
27. **Include pagination metadata** in the response:
    ```json
    {
      "data": [...],
      "meta": {
        "total": 500,
        "page": 3,
        "limit": 20,
        "next_cursor": "eyJpZCI6MTAwfQ=="
      }
    }
    ```
28. **Cap the maximum `limit`** server-side (e.g. 100). Never allow unlimited page sizes.

## Headers

29. **`Location` header on `201 Created`**: Point to the newly created resource URL.
30. **`ETag` and `Last-Modified`** for cacheable resources. Support `If-None-Match` / `If-Modified-Since` for conditional GETs.
31. **`Retry-After`** on `429` and `503` responses.
32. **`X-Request-ID`** (or `X-Correlation-ID`): Accept from the client and echo back; generate one if absent. Log it on every request.
33. **CORS**: Set restrictive `Access-Control-Allow-Origin` in production. Do not use `*` for authenticated APIs.

## Rate Limiting

34. **Enforce rate limits** on all public endpoints. Return `429 Too Many Requests` with a `Retry-After` header.
35. **Expose rate limit state** via response headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.

## Idempotency

36. **Support `Idempotency-Key` header** on `POST` endpoints that create resources or trigger payments/side effects. Store the key and replay the response if the same key is received again within a TTL.

## Documentation

37. **Use OpenAPI 3.x** to document the API. Generate it from code annotations or maintain it alongside code — never let it diverge.
38. **Document every endpoint**: path, method, parameters, request body schema, all possible response codes and bodies, authentication requirements.
39. **Provide a changelog**: Describe what changed between versions.

## Security

40. **Validate and sanitize all inputs**: Reject requests with unexpected fields (strict schema validation).
41. **Apply HTTPS everywhere**: Never expose the API over plain HTTP in any environment.
42. **Set security headers**: `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`.
43. **Protect against mass assignment**: Explicitly allowlist fields that can be set by clients.
