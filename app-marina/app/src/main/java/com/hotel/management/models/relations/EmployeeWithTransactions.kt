package com.hotel.management.models.relations

import androidx.room.Embedded
import androidx.room.Relation
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.models.EmployeeEntity

data class EmployeeWithTransactions(
    @Embedded val employee: EmployeeEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "employee_id"
    )
    val transactions: List<CashTransactionEntity>
)
