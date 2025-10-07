package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.hotel.management.models.CashTransactionEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface CashTransactionDao {

    @Query("SELECT * FROM cash_transactions WHERE register_id = :registerId ORDER BY created_at DESC")
    fun observeTransactionsForRegister(registerId: Long): Flow<List<CashTransactionEntity>>

    @Query("SELECT * FROM cash_transactions WHERE employee_id = :employeeId ORDER BY created_at DESC")
    fun observeTransactionsForEmployee(employeeId: Long): Flow<List<CashTransactionEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(transaction: CashTransactionEntity): Long

    @Delete
    suspend fun delete(transaction: CashTransactionEntity)
}
