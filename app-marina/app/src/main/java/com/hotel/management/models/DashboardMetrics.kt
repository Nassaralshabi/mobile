package com.hotel.management.models

data class DashboardMetrics(
    val availableRooms: Int = 0,
    val occupiedRooms: Int = 0,
    val maintenanceRooms: Int = 0,
    val currentGuests: Int = 0,
    val dailyRevenue: Double = 0.0,
    val cashBalance: Double = 0.0,
    val highPriorityAlerts: Int = 0
)
