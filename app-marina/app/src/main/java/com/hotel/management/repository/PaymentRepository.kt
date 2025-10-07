package com.hotel.management.repository

import com.hotel.management.database.dao.PaymentDao
import com.hotel.management.models.PaymentEntity
import com.hotel.management.utils.HotelApiService
import kotlinx.coroutines.flow.Flow

class PaymentRepository(
    private val paymentDao: PaymentDao,
    private val apiService: HotelApiService
) {

    fun observePayments(): Flow<List<PaymentEntity>> = paymentDao.observePayments()

    fun observePaymentsByMethod(method: String): Flow<List<PaymentEntity>> = paymentDao.observePaymentsByMethod(method)

    fun observePaymentsByDateRange(from: String, to: String): Flow<List<PaymentEntity>> = paymentDao.observePaymentsByDateRange(from, to)

    suspend fun savePayment(payment: PaymentEntity): Long = paymentDao.upsert(payment)

    suspend fun deletePayment(payment: PaymentEntity) = paymentDao.delete(payment)

    suspend fun syncWithRemote() {
        val remotePayments = try {
            apiService.fetchPayments()
        } catch (_: Exception) {
            emptyList()
        }
        remotePayments.forEach { paymentDao.upsert(it) }
    }
}
