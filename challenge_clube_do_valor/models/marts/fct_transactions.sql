{{ config(
    materialized='incremental',
    unique_key='transaction_id'
) }}

SELECT * 
FROM {{ ref('int_transactions') }}

{% if is_incremental() %}
  WHERE transaction_date >= (
    SELECT MAX(transaction_date) FROM {{ this }}
  )
{% endif %}