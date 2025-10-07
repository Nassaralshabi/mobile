package com.hotel.management.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.hotel.management.HotelManagementApp

class AppViewModelFactory(private val app: HotelManagementApp) : ViewModelProvider.Factory {

    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return when {
            modelClass.isAssignableFrom(AuthViewModel::class.java) -> AuthViewModel(app.userRepository, app.preferencesManager) as T
            modelClass.isAssignableFrom(DashboardViewModel::class.java) -> DashboardViewModel(app.bookingRepository, app.roomRepository, app.paymentRepository, app.cashRegisterRepository, app.expenseRepository) as T
            modelClass.isAssignableFrom(BookingsViewModel::class.java) -> BookingsViewModel(app.bookingRepository) as T
            modelClass.isAssignableFrom(BookingDetailsViewModel::class.java) -> BookingDetailsViewModel(app.bookingRepository) as T
            modelClass.isAssignableFrom(BookingEditViewModel::class.java) -> BookingEditViewModel(app.bookingRepository, app.roomRepository) as T
            modelClass.isAssignableFrom(RoomsViewModel::class.java) -> RoomsViewModel(app.roomRepository) as T
            modelClass.isAssignableFrom(PaymentsViewModel::class.java) -> PaymentsViewModel(app.paymentRepository) as T
            modelClass.isAssignableFrom(AddPaymentViewModel::class.java) -> AddPaymentViewModel(app.paymentRepository, app.bookingRepository) as T
            modelClass.isAssignableFrom(CashRegisterViewModel::class.java) -> CashRegisterViewModel(app.cashRegisterRepository) as T
            modelClass.isAssignableFrom(ExpensesViewModel::class.java) -> ExpensesViewModel(app.expenseRepository) as T
            modelClass.isAssignableFrom(AddExpenseViewModel::class.java) -> AddExpenseViewModel(app.expenseRepository) as T
            modelClass.isAssignableFrom(EmployeesViewModel::class.java) -> EmployeesViewModel(app.employeeRepository) as T
            modelClass.isAssignableFrom(InvoicesViewModel::class.java) -> InvoicesViewModel(app.invoiceRepository) as T
            modelClass.isAssignableFrom(ReportsViewModel::class.java) -> ReportsViewModel(app.paymentRepository, app.expenseRepository, app.bookingRepository, app.cashRegisterRepository) as T
            modelClass.isAssignableFrom(SettingsViewModel::class.java) -> SettingsViewModel(app.preferencesManager, app.userRepository) as T
            modelClass.isAssignableFrom(ActivityLogViewModel::class.java) -> ActivityLogViewModel() as T
            else -> throw IllegalArgumentException("Unknown ViewModel class ${modelClass.simpleName}")
        }
    }
}
