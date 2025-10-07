package com.hotel.management.models.relations

import androidx.room.Embedded
import androidx.room.Relation
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.CashTransactionEntity

data class CashRegisterWithTransactions(
    @Embedded val register: CashRegisterEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "register_id"
    )
    val transactions: List<CashTransactionEntity>
)
