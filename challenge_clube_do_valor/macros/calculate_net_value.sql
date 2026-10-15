{% macro calc_net_value(transaction_type, value_column) %}
    case 
        when upper({{ transaction_type }}) = 'BUY' then {{ value_column }}
        when upper({{ transaction_type }}) = 'SELL' then -{{ value_column }}
        else 0
    end
{% endmacro %}