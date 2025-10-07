package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.Instant

@Entity(tableName = "cash_register")
data class CashRegisterEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "opening_balance")
    val openingBalance: Double,
    @ColumnInfo(name = "closing_balance")
    val closingBalance: Double? = null,
    @ColumnInfo(name = "total_income")
    val totalIncome: Double = 0.0,
    @ColumnInfo(name = "total_expense")
    val totalExpense: Double = 0.0,
    @ColumnInfo(name = "status")
    val status: String,
    @ColumnInfo(name = "opened_by")
    val openedBy: String,
    @ColumnInfo(name = "closed_by")
    val closedBy: String? = null,
    @ColumnInfo(name = "opened_at")
    val openedAt: Instant,
    @ColumnInfo(name = "closed_at")
    val closedAt: Instant? = null
)
