package com.hotel.management.models

data class ReportSummary(
    val revenueByDay: Map<String, Double> = emptyMap(),
    val revenueByMonth: Map<String, Double> = emptyMap(),
    val occupancyRate: Double = 0.0,
    val expenseTotals: Map<String, Double> = emptyMap(),
    val paymentMethodBreakdown: Map<String, Double> = emptyMap(),
    val cashRegisterTotals: Map<String, Double> = emptyMap()
)
