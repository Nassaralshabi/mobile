package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant

@Entity(
    tableName = "cash_transactions",
    foreignKeys = [
        ForeignKey(
            entity = CashRegisterEntity::class,
            parentColumns = ["id"],
            childColumns = ["register_id"],
            onDelete = ForeignKey.CASCADE
        ),
        ForeignKey(
            entity = EmployeeEntity::class,
            parentColumns = ["id"],
            childColumns = ["employee_id"],
            onDelete = ForeignKey.SET_NULL
        )
    ],
    indices = [Index(value = ["register_id"]), Index(value = ["employee_id"])]
)
data class CashTransactionEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "register_id")
    val registerId: Long,
    @ColumnInfo(name = "type")
    val type: String,
    @ColumnInfo(name = "amount")
    val amount: Double,
    @ColumnInfo(name = "description")
    val description: String? = null,
    @ColumnInfo(name = "performed_by")
    val performedBy: String? = null,
    @ColumnInfo(name = "employee_id")
    val employeeId: Long? = null,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant = Instant.now()
)
