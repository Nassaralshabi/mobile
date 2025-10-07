package com.hotel.management.utils

import com.hotel.management.models.BookingEntity
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.EmployeeEntity
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.InvoiceEntity
import com.hotel.management.models.PaymentEntity
import com.hotel.management.models.RoomEntity
import com.hotel.management.models.SupplierEntity
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path
import retrofit2.http.Query

interface HotelApiService {

    @GET("/api/v1/bookings")
    suspend fun fetchBookings(@Query("updated_since") updatedSince: String? = null): List<BookingEntity>

    @GET("/api/v1/bookings/{id}")
    suspend fun fetchBooking(@Path("id") id: Long): BookingEntity

    @POST("/api/v1/sync")
    suspend fun syncChanges()

    @GET("/api/v1/payments")
    suspend fun fetchPayments(@Query("date_from") from: String? = null, @Query("date_to") to: String? = null): List<PaymentEntity>

    @GET("/api/v1/rooms")
    suspend fun fetchRooms(): List<RoomEntity>

    @GET("/api/v1/expenses")
    suspend fun fetchExpenses(): List<ExpenseEntity>

    @GET("/api/v1/employees")
    suspend fun fetchEmployees(): List<EmployeeEntity>

    @GET("/api/v1/cash-registers")
    suspend fun fetchCashRegisters(): List<CashRegisterEntity>

    @GET("/api/v1/invoices")
    suspend fun fetchInvoices(): List<InvoiceEntity>

    @GET("/api/v1/suppliers")
    suspend fun fetchSuppliers(): List<SupplierEntity>
}
