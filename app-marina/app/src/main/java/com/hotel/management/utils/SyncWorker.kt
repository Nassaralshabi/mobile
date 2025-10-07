package com.hotel.management.utils

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.hotel.management.HotelManagementApp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class SyncWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        val app = applicationContext as HotelManagementApp
        return@withContext try {
            app.bookingRepository.syncWithRemote()
            app.paymentRepository.syncWithRemote()
            app.expenseRepository.syncWithRemote()
            app.roomRepository.syncWithRemote()
            app.employeeRepository.syncWithRemote()
            app.cashRegisterRepository.syncWithRemote()
            Result.success()
        } catch (ex: Exception) {
            Result.retry()
        }
    }
}
