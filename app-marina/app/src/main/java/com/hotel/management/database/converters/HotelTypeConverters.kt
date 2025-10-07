package com.hotel.management.database.converters

import androidx.room.TypeConverter
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime

class HotelTypeConverters {

    @TypeConverter
    fun fromIsoDate(value: String?): LocalDate? = value?.let { LocalDate.parse(it) }

    @TypeConverter
    fun localDateToIso(value: LocalDate?): String? = value?.toString()

    @TypeConverter
    fun fromIsoDateTime(value: String?): LocalDateTime? = value?.let { LocalDateTime.parse(it) }

    @TypeConverter
    fun localDateTimeToIso(value: LocalDateTime?): String? = value?.toString()

    @TypeConverter
    fun fromEpoch(value: Long?): Instant? = value?.let { Instant.ofEpochMilli(it) }

    @TypeConverter
    fun instantToEpoch(value: Instant?): Long? = value?.toEpochMilli()

    @TypeConverter
    fun fromDelimitedList(value: String?): List<String>? = value?.takeIf { it.isNotBlank() }?.split("|")?.map { it.trim() }

    @TypeConverter
    fun listToDelimited(value: List<String>?): String? = value?.joinToString(separator = "|")
}
