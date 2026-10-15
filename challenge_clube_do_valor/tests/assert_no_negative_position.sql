SELECT
    client_id,
    asset_ticker,
    net_quantity
FROM {{ ref('mart_client_portfolio') }}
WHERE net_quantity < 0