package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.hotel.management.models.EmployeeEntity
import com.hotel.management.models.relations.EmployeeWithTransactions
import kotlinx.coroutines.flow.Flow

@Dao
interface EmployeeDao {

    @Query("SELECT * FROM employees ORDER BY name")
    fun observeEmployees(): Flow<List<EmployeeEntity>>

    @Query("SELECT * FROM employees WHERE status = :status ORDER BY name")
    fun observeEmployeesByStatus(status: String): Flow<List<EmployeeEntity>>

    @Transaction
    @Query("SELECT * FROM employees WHERE id = :employeeId")
    fun observeEmployeeWithTransactions(employeeId: Long): Flow<EmployeeWithTransactions?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(employee: EmployeeEntity): Long

    @Update
    suspend fun update(employee: EmployeeEntity)

    @Delete
    suspend fun delete(employee: EmployeeEntity)
}
