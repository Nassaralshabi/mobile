package com.hotel.management.models.relations

import androidx.room.Embedded
import androidx.room.Relation
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.SupplierEntity

data class SupplierWithExpenses(
    @Embedded val supplier: SupplierEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "supplier_id"
    )
    val expenses: List<ExpenseEntity>
)
