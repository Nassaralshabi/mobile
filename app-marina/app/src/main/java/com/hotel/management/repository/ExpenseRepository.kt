package com.hotel.management.repository

import com.hotel.management.database.dao.ExpenseDao
import com.hotel.management.database.dao.SupplierDao
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.SupplierEntity
import com.hotel.management.models.relations.SupplierWithExpenses
import com.hotel.management.utils.HotelApiService
import kotlinx.coroutines.flow.Flow

class ExpenseRepository(
    private val expenseDao: ExpenseDao,
    private val supplierDao: SupplierDao,
    private val apiService: HotelApiService
) {

    fun observeExpenses(): Flow<List<ExpenseEntity>> = expenseDao.observeExpenses()

    fun observeExpensesByCategory(category: String): Flow<List<ExpenseEntity>> = expenseDao.observeExpensesByCategory(category)

    fun observeSupplierWithExpenses(supplierId: Long): Flow<SupplierWithExpenses?> = expenseDao.observeSupplierWithExpenses(supplierId)

    fun observeSuppliers(): Flow<List<SupplierEntity>> = supplierDao.observeSuppliers()

    suspend fun saveExpense(expense: ExpenseEntity): Long = expenseDao.upsert(expense)

    suspend fun saveSupplier(supplier: SupplierEntity): Long = supplierDao.upsert(supplier)

    suspend fun deleteExpense(expense: ExpenseEntity) = expenseDao.delete(expense)

    suspend fun deleteSupplier(supplier: SupplierEntity) = supplierDao.delete(supplier)

    suspend fun syncWithRemote() {
        val remoteExpenses = try {
            apiService.fetchExpenses()
        } catch (_: Exception) {
            emptyList()
        }
        val remoteSuppliers = try {
            apiService.fetchSuppliers()
        } catch (_: Exception) {
            emptyList()
        }
        remoteSuppliers.forEach { supplierDao.upsert(it) }
        remoteExpenses.forEach { expenseDao.upsert(it) }
    }
}
