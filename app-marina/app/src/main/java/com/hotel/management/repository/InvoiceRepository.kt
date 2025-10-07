package com.hotel.management.repository

import com.hotel.management.database.dao.InvoiceDao
import com.hotel.management.models.InvoiceEntity
import com.hotel.management.utils.HotelApiService
import kotlinx.coroutines.flow.Flow

class InvoiceRepository(
    private val invoiceDao: InvoiceDao,
    private val apiService: HotelApiService
) {

    fun observeInvoices(): Flow<List<InvoiceEntity>> = invoiceDao.observeInvoices()

    fun observeInvoicesByStatus(status: String): Flow<List<InvoiceEntity>> = invoiceDao.observeInvoicesByStatus(status)

    suspend fun saveInvoice(invoice: InvoiceEntity): Long = invoiceDao.upsert(invoice)

    suspend fun deleteInvoice(invoice: InvoiceEntity) = invoiceDao.delete(invoice)

    suspend fun syncWithRemote() {
        val remoteInvoices = try {
            apiService.fetchInvoices()
        } catch (_: Exception) {
            emptyList()
        }
        remoteInvoices.forEach { invoiceDao.upsert(it) }
    }
}
