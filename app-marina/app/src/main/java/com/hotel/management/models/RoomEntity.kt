package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "rooms")
data class RoomEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "room_number")
    val roomNumber: String,
    @ColumnInfo(name = "room_type")
    val roomType: String,
    @ColumnInfo(name = "price_per_night")
    val pricePerNight: Double,
    @ColumnInfo(name = "capacity")
    val capacity: Int,
    @ColumnInfo(name = "status")
    val status: String,
    @ColumnInfo(name = "description")
    val description: String? = null,
    @ColumnInfo(name = "amenities")
    val amenities: List<String>? = null,
    @ColumnInfo(name = "floor")
    val floor: Int? = null
)
