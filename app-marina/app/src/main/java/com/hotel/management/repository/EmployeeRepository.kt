package com.hotel.management.repository

import com.hotel.management.database.dao.CashTransactionDao
import com.hotel.management.database.dao.EmployeeDao
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.models.EmployeeEntity
import com.hotel.management.models.relations.EmployeeWithTransactions
import com.hotel.management.utils.HotelApiService
import kotlinx.coroutines.flow.Flow

class EmployeeRepository(
    private val employeeDao: EmployeeDao,
    private val transactionDao: CashTransactionDao,
    private val apiService: HotelApiService
) {

    fun observeEmployees(): Flow<List<EmployeeEntity>> = employeeDao.observeEmployees()

    fun observeEmployeesByStatus(status: String): Flow<List<EmployeeEntity>> = employeeDao.observeEmployeesByStatus(status)

    fun observeEmployeeDetails(employeeId: Long): Flow<EmployeeWithTransactions?> = employeeDao.observeEmployeeWithTransactions(employeeId)

    fun observeWithdrawals(employeeId: Long): Flow<List<CashTransactionEntity>> = transactionDao.observeTransactionsForEmployee(employeeId)

    suspend fun saveEmployee(employee: EmployeeEntity): Long = employeeDao.upsert(employee)

    suspend fun updateEmployee(employee: EmployeeEntity) = employeeDao.update(employee)

    suspend fun recordWithdrawal(transaction: CashTransactionEntity): Long = transactionDao.insert(transaction)

    suspend fun deleteEmployee(employee: EmployeeEntity) = employeeDao.delete(employee)

    suspend fun syncWithRemote() {
        val remoteEmployees = try {
            apiService.fetchEmployees()
        } catch (_: Exception) {
            emptyList()
        }
        remoteEmployees.forEach { employeeDao.upsert(it) }
    }
}
