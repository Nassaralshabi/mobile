package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import com.hotel.management.models.ReportSummary
import com.hotel.management.repository.BookingRepository
import com.hotel.management.repository.CashRegisterRepository
import com.hotel.management.repository.ExpenseRepository
import com.hotel.management.repository.PaymentRepository
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine

class ReportsViewModel(
    private val paymentRepository: PaymentRepository,
    private val expenseRepository: ExpenseRepository,
    private val bookingRepository: BookingRepository,
    private val cashRegisterRepository: CashRegisterRepository
) : ViewModel() {

    private val dateRange = MutableStateFlow<Pair<LocalDate?, LocalDate?>>(null to null)
    private val formatterDay = DateTimeFormatter.ofPattern("yyyy-MM-dd")
    private val formatterMonth = DateTimeFormatter.ofPattern("yyyy-MM")

    private val summaryFlow = combine(
        paymentRepository.observePayments(),
        expenseRepository.observeExpenses(),
        bookingRepository.observeBookings(),
        cashRegisterRepository.observeRegisters(),
        dateRange
    ) { payments, expenses, bookings, registers, range ->
        val filteredPayments = payments.filter { payment ->
            val date = payment.paymentDate
            range.within(date)
        }
        val filteredExpenses = expenses.filter { expense ->
            range.within(expense.expenseDate)
        }
        val filteredBookings = bookings.filter { booking ->
            range.within(booking.checkInDate) || range.within(booking.checkOutDate)
        }
        val revenueByDay = filteredPayments.groupBy { it.paymentDate.format(formatterDay) }
            .mapValues { entry -> entry.value.sumOf { it.amount } }
        val revenueByMonth = filteredPayments.groupBy { it.paymentDate.withDayOfMonth(1).format(formatterMonth) }
            .mapValues { entry -> entry.value.sumOf { it.amount } }
        val expenseTotals = filteredExpenses.groupBy { it.category }
            .mapValues { entry -> entry.value.sumOf { it.amount } }
        val paymentMethodBreakdown = filteredPayments.groupBy { it.paymentMethod }
            .mapValues { entry -> entry.value.sumOf { it.amount } }
        val cashRegisterTotals = registers.associate { register ->
            val balance = register.closingBalance ?: register.openingBalance
            register.status to balance
        }
        val occupancyRate = if (filteredBookings.isEmpty()) 0.0 else filteredBookings.count { it.status in listOf("checked_in", "completed") }.toDouble() / filteredBookings.size
        ReportSummary(
            revenueByDay = revenueByDay,
            revenueByMonth = revenueByMonth,
            occupancyRate = occupancyRate,
            expenseTotals = expenseTotals,
            paymentMethodBreakdown = paymentMethodBreakdown,
            cashRegisterTotals = cashRegisterTotals
        )
    }

    val reportSummary: LiveData<ReportSummary> = summaryFlow.asLiveData()

    fun setDateRange(start: LocalDate?, end: LocalDate?) {
        dateRange.value = start to end
    }

    private fun Pair<LocalDate?, LocalDate?>.within(date: LocalDate): Boolean {
        val start = first
        val end = second
        return when {
            start != null && end != null -> !date.isBefore(start) && !date.isAfter(end)
            start != null -> !date.isBefore(start)
            end != null -> !date.isAfter(end)
            else -> true
        }
    }
}
