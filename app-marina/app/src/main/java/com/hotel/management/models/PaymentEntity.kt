package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "payments",
    foreignKeys = [
        ForeignKey(
            entity = BookingEntity::class,
            parentColumns = ["id"],
            childColumns = ["booking_id"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["booking_id"])]
)
data class PaymentEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "booking_id")
    val bookingId: Long,
    @ColumnInfo(name = "amount")
    val amount: Double,
    @ColumnInfo(name = "payment_method")
    val paymentMethod: String,
    @ColumnInfo(name = "revenue_type")
    val revenueType: String,
    @ColumnInfo(name = "receipt_number")
    val receiptNumber: String? = null,
    @ColumnInfo(name = "description")
    val description: String? = null,
    @ColumnInfo(name = "notes")
    val notes: String? = null,
    @ColumnInfo(name = "payment_date")
    val paymentDate: LocalDate,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant? = null
)
