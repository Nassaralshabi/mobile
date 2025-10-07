package com.hotel.management.models

import java.time.Instant

data class ActivityLogItem(
    val id: Long,
    val userName: String,
    val actionType: String,
    val description: String,
    val createdAt: Instant
)
