SELECT
    CAST(transaction_id AS string) AS transaction_id,
    CAST(client_id AS string) AS client_id,
    CAST(asset_ticker AS string) AS asset_ticker,
    UPPER(CAST(operation AS string)) AS transaction_type,
    CAST(quantity AS numeric) AS quantity,
    CAST(unit_price AS numeric) AS price,
    CAST(transaction_date AS date) AS transaction_date
FROM {{ ref('transactions') }}
WHERE transaction_id IS NOT NULL
  AND UPPER(operation) IN ('BUY', 'SELL')