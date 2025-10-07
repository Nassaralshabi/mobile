package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.relations.CashRegisterWithTransactions
import kotlinx.coroutines.flow.Flow

@Dao
interface CashRegisterDao {

    @Query("SELECT * FROM cash_register ORDER BY opened_at DESC")
    fun observeRegisters(): Flow<List<CashRegisterEntity>>

    @Query("SELECT * FROM cash_register WHERE status = :status ORDER BY opened_at DESC LIMIT 1")
    fun observeLatestByStatus(status: String): Flow<CashRegisterEntity?>

    @Transaction
    @Query("SELECT * FROM cash_register WHERE id = :registerId")
    fun observeRegisterWithTransactions(registerId: Long): Flow<CashRegisterWithTransactions?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(register: CashRegisterEntity): Long

    @Update
    suspend fun update(register: CashRegisterEntity)
}
