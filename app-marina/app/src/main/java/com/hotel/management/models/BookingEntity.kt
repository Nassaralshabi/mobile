package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDate

@Entity(tableName = "bookings")
data class BookingEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "guest_name")
    val guestName: String,
    @ColumnInfo(name = "guest_phone")
    val guestPhone: String,
    @ColumnInfo(name = "guest_email")
    val guestEmail: String,
    @ColumnInfo(name = "guest_id")
    val guestId: String? = null,
    @ColumnInfo(name = "nationality")
    val nationality: String? = null,
    @ColumnInfo(name = "address")
    val address: String? = null,
    @ColumnInfo(name = "room_number")
    val roomNumber: Int,
    @ColumnInfo(name = "check_in_date")
    val checkInDate: LocalDate,
    @ColumnInfo(name = "check_out_date")
    val checkOutDate: LocalDate,
    @ColumnInfo(name = "status")
    val status: String,
    @ColumnInfo(name = "notes")
    val notes: String? = null,
    @ColumnInfo(name = "calculated_nights")
    val calculatedNights: Int? = null,
    @ColumnInfo(name = "total_amount")
    val totalAmount: Double = 0.0,
    @ColumnInfo(name = "paid_amount")
    val paidAmount: Double = 0.0,
    @ColumnInfo(name = "discount_amount")
    val discountAmount: Double? = null,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant? = null,
    @ColumnInfo(name = "updated_at")
    val updatedAt: Instant? = null
)
