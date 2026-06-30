"""
Python Metric Collection Function.
"""

import pandas as pd


def record_metric(
    engine,
    metric_name,
    metric_value,
    warning_threshold,
    critical_threshold,
    source_system
):
    # Decide the dashboard status using the threshold values.
    if metric_value >= critical_threshold:
        status = "Critical"
    elif metric_value >= warning_threshold:
        status = "Warning"
    else:
        status = "Normal"

    # Put one monitoring metric into a simple table-shaped DataFrame.
    metric_df = pd.DataFrame([{
        "MetricName": metric_name,
        "MetricValue": metric_value,
        "WarningThreshold": warning_threshold,
        "CriticalThreshold": critical_threshold,
        "Status": status,
        "SourceSystem": source_system
    }])

    # Append the metric row to SQL Server for dashboard history.
    metric_df.to_sql(
        "MonitoringMetric",
        engine,
        schema="dbo",
        if_exists="append",
        index=False
    )
