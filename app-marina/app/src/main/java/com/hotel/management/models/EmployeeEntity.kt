package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDate

@Entity(tableName = "employees")
data class EmployeeEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "name")
    val name: String,
    @ColumnInfo(name = "position")
    val position: String,
    @ColumnInfo(name = "basic_salary")
    val basicSalary: Double,
    @ColumnInfo(name = "status")
    val status: String,
    @ColumnInfo(name = "phone")
    val phone: String? = null,
    @ColumnInfo(name = "email")
    val email: String? = null,
    @ColumnInfo(name = "hire_date")
    val hireDate: LocalDate? = null,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant? = null
)
