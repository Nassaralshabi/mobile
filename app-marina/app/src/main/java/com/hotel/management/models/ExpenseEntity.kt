package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "expenses",
    foreignKeys = [
        ForeignKey(
            entity = SupplierEntity::class,
            parentColumns = ["id"],
            childColumns = ["supplier_id"],
            onDelete = ForeignKey.SET_NULL
        )
    ],
    indices = [Index(value = ["supplier_id"])]
)
data class ExpenseEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "category")
    val category: String,
    @ColumnInfo(name = "description")
    val description: String,
    @ColumnInfo(name = "amount")
    val amount: Double,
    @ColumnInfo(name = "supplier_id")
    val supplierId: Long? = null,
    @ColumnInfo(name = "expense_date")
    val expenseDate: LocalDate,
    @ColumnInfo(name = "approval_status")
    val approvalStatus: String = "pending",
    @ColumnInfo(name = "receipt_path")
    val receiptPath: String? = null,
    @ColumnInfo(name = "added_by")
    val addedBy: String? = null,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant? = null
)
