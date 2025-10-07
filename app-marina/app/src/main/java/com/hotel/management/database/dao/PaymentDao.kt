package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.hotel.management.models.PaymentEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PaymentDao {

    @Query("SELECT * FROM payments ORDER BY payment_date DESC")
    fun observePayments(): Flow<List<PaymentEntity>>

    @Query("SELECT * FROM payments WHERE payment_date BETWEEN :from AND :to ORDER BY payment_date DESC")
    fun observePaymentsByDateRange(from: String, to: String): Flow<List<PaymentEntity>>

    @Query("SELECT * FROM payments WHERE payment_method = :method ORDER BY payment_date DESC")
    fun observePaymentsByMethod(method: String): Flow<List<PaymentEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(payment: PaymentEntity): Long

    @Delete
    suspend fun delete(payment: PaymentEntity)
}
