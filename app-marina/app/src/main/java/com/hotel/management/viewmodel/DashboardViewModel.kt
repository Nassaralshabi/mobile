package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import com.hotel.management.models.DashboardMetrics
import com.hotel.management.repository.BookingRepository
import com.hotel.management.repository.CashRegisterRepository
import com.hotel.management.repository.ExpenseRepository
import com.hotel.management.repository.PaymentRepository
import com.hotel.management.repository.RoomRepository
import java.time.LocalDate
import kotlinx.coroutines.flow.combine

class DashboardViewModel(
    private val bookingRepository: BookingRepository,
    private val roomRepository: RoomRepository,
    private val paymentRepository: PaymentRepository,
    private val cashRegisterRepository: CashRegisterRepository,
    private val expenseRepository: ExpenseRepository
) : ViewModel() {

    private val metricsFlow = combine(
        bookingRepository.observeBookingsWithNotes(),
        roomRepository.observeRooms(),
        paymentRepository.observePayments(),
        cashRegisterRepository.observeLatestOpenRegister(),
        expenseRepository.observeExpenses()
    ) { bookingsWithNotes, rooms, payments, register, _ ->
        val today = LocalDate.now()
        val dailyRevenue = payments.filter { it.paymentDate == today }.sumOf { it.amount }
        val availableRooms = rooms.count { it.status == "available" }
        val occupiedRooms = rooms.count { it.status == "occupied" }
        val maintenanceRooms = rooms.count { it.status == "maintenance" }
        val currentGuests = bookingsWithNotes.count { it.booking.status in listOf("checked_in", "inhouse") }
        val cashBalance = register?.closingBalance ?: register?.openingBalance ?: 0.0
        val highAlerts = bookingsWithNotes.sumOf { booking -> booking.notes.count { it.alertType == "high" } }
        DashboardMetrics(
            availableRooms = availableRooms,
            occupiedRooms = occupiedRooms,
            maintenanceRooms = maintenanceRooms,
            currentGuests = currentGuests,
            dailyRevenue = dailyRevenue,
            cashBalance = cashBalance,
            highPriorityAlerts = highAlerts
        )
    }

    val metrics: LiveData<DashboardMetrics> = metricsFlow.asLiveData()
}
