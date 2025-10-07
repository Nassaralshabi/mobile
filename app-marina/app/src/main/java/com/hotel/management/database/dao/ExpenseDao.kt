package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.relations.SupplierWithExpenses
import kotlinx.coroutines.flow.Flow

@Dao
interface ExpenseDao {

    @Query("SELECT * FROM expenses ORDER BY expense_date DESC")
    fun observeExpenses(): Flow<List<ExpenseEntity>>

    @Query("SELECT * FROM expenses WHERE category = :category ORDER BY expense_date DESC")
    fun observeExpensesByCategory(category: String): Flow<List<ExpenseEntity>>

    @Transaction
    @Query("SELECT * FROM suppliers WHERE id = :supplierId")
    fun observeSupplierWithExpenses(supplierId: Long): Flow<SupplierWithExpenses?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(expense: ExpenseEntity): Long

    @Delete
    suspend fun delete(expense: ExpenseEntity)
}
