package com.hotel.management.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.hotel.management.database.converters.HotelTypeConverters
import com.hotel.management.database.dao.BookingDao
import com.hotel.management.database.dao.BookingNoteDao
import com.hotel.management.database.dao.CashRegisterDao
import com.hotel.management.database.dao.CashTransactionDao
import com.hotel.management.database.dao.EmployeeDao
import com.hotel.management.database.dao.ExpenseDao
import com.hotel.management.database.dao.InvoiceDao
import com.hotel.management.database.dao.PaymentDao
import com.hotel.management.database.dao.RoomDao
import com.hotel.management.database.dao.SupplierDao
import com.hotel.management.database.dao.UserDao
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.BookingNoteEntity
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.models.EmployeeEntity
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.InvoiceEntity
import com.hotel.management.models.PaymentEntity
import com.hotel.management.models.RoomEntity
import com.hotel.management.models.SupplierEntity
import com.hotel.management.models.UserEntity
import com.hotel.management.utils.SecurityUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

@Database(
    entities = [
        BookingEntity::class,
        BookingNoteEntity::class,
        RoomEntity::class,
        PaymentEntity::class,
        ExpenseEntity::class,
        EmployeeEntity::class,
        CashRegisterEntity::class,
        CashTransactionEntity::class,
        InvoiceEntity::class,
        SupplierEntity::class,
        UserEntity::class
    ],
    version = 1,
    exportSchema = true
)
@TypeConverters(HotelTypeConverters::class)
abstract class HotelDatabase : RoomDatabase() {

    abstract fun bookingDao(): BookingDao
    abstract fun bookingNoteDao(): BookingNoteDao
    abstract fun roomDao(): RoomDao
    abstract fun paymentDao(): PaymentDao
    abstract fun expenseDao(): ExpenseDao
    abstract fun employeeDao(): EmployeeDao
    abstract fun cashRegisterDao(): CashRegisterDao
    abstract fun cashTransactionDao(): CashTransactionDao
    abstract fun invoiceDao(): InvoiceDao
    abstract fun supplierDao(): SupplierDao
    abstract fun userDao(): UserDao

    companion object {
        @Volatile
        private var INSTANCE: HotelDatabase? = null

        fun getInstance(context: Context, scope: CoroutineScope): HotelDatabase =
            INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    HotelDatabase::class.java,
                    "hotel_management.db"
                )
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                scope.launch {
                    // Pre-populate admin user if it doesn't exist
                    prepopulateDatabase(instance)
                }
                instance
            }

        private suspend fun prepopulateDatabase(database: HotelDatabase) {
            val userDao = database.userDao()
            
            // Check if admin user already exists
            val adminUser = userDao.findByUsername("admin")
            if (adminUser == null) {
                // Create admin user with admin/1234 credentials
                val salt = SecurityUtils.generateSalt()
                val passwordHash = SecurityUtils.hashPassword("1234", salt)
                
                val adminEntity = UserEntity(
                    username = "admin",
                    passwordHash = passwordHash,
                    salt = salt,
                    role = "admin",
                    displayName = "المسؤول",
                    isActive = true
                )
                
                userDao.upsert(adminEntity)
            }
        }
    }
}
