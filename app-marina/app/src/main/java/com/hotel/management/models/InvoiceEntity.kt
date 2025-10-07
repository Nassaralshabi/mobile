package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDate

@Entity(
    tableName = "invoices",
    foreignKeys = [
        ForeignKey(
            entity = BookingEntity::class,
            parentColumns = ["id"],
            childColumns = ["booking_id"],
            onDelete = ForeignKey.SET_NULL
        )
    ],
    indices = [Index(value = ["booking_id"], unique = false), Index(value = ["invoice_number"], unique = true)]
)
data class InvoiceEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "booking_id")
    val bookingId: Long? = null,
    @ColumnInfo(name = "invoice_number")
    val invoiceNumber: String,
    @ColumnInfo(name = "total_amount")
    val totalAmount: Double,
    @ColumnInfo(name = "tax_amount")
    val taxAmount: Double = 0.0,
    @ColumnInfo(name = "discount_amount")
    val discountAmount: Double = 0.0,
    @ColumnInfo(name = "status")
    val status: String,
    @ColumnInfo(name = "issued_at")
    val issuedAt: LocalDate,
    @ColumnInfo(name = "due_at")
    val dueAt: LocalDate? = null,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant = Instant.now()
)
