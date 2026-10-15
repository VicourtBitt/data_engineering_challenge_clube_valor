SELECT
    CAST(client_id AS string) AS client_id,
    CAST(name AS string) AS client_name,
    CAST(city AS string) AS city,
    CAST(state AS string) AS state,
    CAST(created_at AS date) AS created_at
FROM {{ ref('clients') }}
WHERE client_id IS NOT NULL