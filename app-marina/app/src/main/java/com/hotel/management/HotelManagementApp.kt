package com.hotel.management

import android.app.Application
import android.content.Context
import androidx.work.Configuration
import androidx.work.WorkManager
import com.hotel.management.database.HotelDatabase
import com.hotel.management.repository.BookingRepository
import com.hotel.management.repository.CashRegisterRepository
import com.hotel.management.repository.EmployeeRepository
import com.hotel.management.repository.ExpenseRepository
import com.hotel.management.repository.InvoiceRepository
import com.hotel.management.repository.PaymentRepository
import com.hotel.management.repository.RoomRepository
import com.hotel.management.repository.UserRepository
import com.hotel.management.utils.HotelApiService
import com.hotel.management.utils.NetworkClient
import com.hotel.management.utils.PreferencesManager
import com.hotel.management.utils.SyncScheduler
import com.hotel.management.utils.WorkManagerInitializer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob

class HotelManagementApp : Application(), Configuration.Provider {

    private val applicationScope = CoroutineScope(SupervisorJob())

    val preferencesManager by lazy { PreferencesManager(this) }
    val database by lazy { HotelDatabase.getInstance(this, applicationScope) }
    val apiService: HotelApiService by lazy {
        NetworkClient.createRetrofit(this, preferencesManager).create(HotelApiService::class.java)
    }

    val bookingRepository by lazy { BookingRepository(database.bookingDao(), database.bookingNoteDao(), apiService) }
    val roomRepository by lazy { RoomRepository(database.roomDao(), apiService) }
    val paymentRepository by lazy { PaymentRepository(database.paymentDao(), apiService) }
    val expenseRepository by lazy { ExpenseRepository(database.expenseDao(), database.supplierDao(), apiService) }
    val employeeRepository by lazy { EmployeeRepository(database.employeeDao(), database.cashTransactionDao(), apiService) }
    val cashRegisterRepository by lazy { CashRegisterRepository(database.cashRegisterDao(), database.cashTransactionDao(), apiService) }
    val invoiceRepository by lazy { InvoiceRepository(database.invoiceDao(), apiService) }
    val userRepository by lazy { UserRepository(database.userDao()) }

    override fun onCreate() {
        super.onCreate()
        // WorkManager is automatically initialized via Configuration.Provider
        SyncScheduler.schedulePeriodicSync(WorkManager.getInstance(this))
    }

    override val workManagerConfiguration: Configuration by lazy {
        WorkManagerInitializer.provideConfiguration(this)
    }

    companion object {
        fun context(application: Application): Context = application.applicationContext
    }
}
