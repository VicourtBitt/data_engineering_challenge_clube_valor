SELECT
    client_id,
    asset_ticker,
    SUM({{ calc_net_value('transaction_type', 'quantity') }}) AS net_quantity,
    SUM({{ calc_net_value('transaction_type', 'financial_volume') }}) AS net_financial_volume
FROM {{ ref('fct_transactions') }}
GROUP BY 1, 2