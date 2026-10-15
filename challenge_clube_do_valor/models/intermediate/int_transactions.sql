SELECT
    transaction_id,
    client_id,
    asset_ticker,
    transaction_type,
    quantity,
    price,
    (quantity * price) AS financial_volume,
    transaction_date
FROM {{ ref('stg_transactions') }}