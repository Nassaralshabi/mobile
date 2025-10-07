package com.hotel.management.repository

import com.hotel.management.database.dao.CashRegisterDao
import com.hotel.management.database.dao.CashTransactionDao
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.models.relations.CashRegisterWithTransactions
import com.hotel.management.utils.HotelApiService
import kotlinx.coroutines.flow.Flow

class CashRegisterRepository(
    private val cashRegisterDao: CashRegisterDao,
    private val transactionDao: CashTransactionDao,
    private val apiService: HotelApiService
) {

    fun observeRegisters(): Flow<List<CashRegisterEntity>> = cashRegisterDao.observeRegisters()

    fun observeLatestOpenRegister(): Flow<CashRegisterEntity?> = cashRegisterDao.observeLatestByStatus("open")

    fun observeRegisterDetails(registerId: Long): Flow<CashRegisterWithTransactions?> = cashRegisterDao.observeRegisterWithTransactions(registerId)

    fun observeTransactions(registerId: Long): Flow<List<CashTransactionEntity>> = transactionDao.observeTransactionsForRegister(registerId)

    suspend fun openRegister(register: CashRegisterEntity): Long = cashRegisterDao.insert(register)

    suspend fun updateRegister(register: CashRegisterEntity) = cashRegisterDao.update(register)

    suspend fun addTransaction(transaction: CashTransactionEntity): Long = transactionDao.insert(transaction)

    suspend fun deleteTransaction(transaction: CashTransactionEntity) = transactionDao.delete(transaction)

    suspend fun syncWithRemote() {
        val remoteRegisters = try {
            apiService.fetchCashRegisters()
        } catch (_: Exception) {
            emptyList()
        }
        remoteRegisters.forEach { cashRegisterDao.insert(it) }
    }
}
