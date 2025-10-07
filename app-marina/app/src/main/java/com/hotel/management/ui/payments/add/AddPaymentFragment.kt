package com.hotel.management.ui.payments.add

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.hotel.management.HotelManagementApp
import com.hotel.management.databinding.FragmentAddPaymentBinding
import com.hotel.management.models.PaymentEntity
import com.hotel.management.utils.Result
import com.hotel.management.viewmodel.AddPaymentViewModel
import com.hotel.management.viewmodel.AppViewModelFactory
import java.time.LocalDate

class AddPaymentFragment : Fragment() {

    private var _binding: FragmentAddPaymentBinding? = null
    private val binding get() = _binding!!

    private val viewModel: AddPaymentViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private var selectedBookingId: Long? = null
    private var currentBookings: List<com.hotel.management.models.BookingEntity> = emptyList()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentAddPaymentBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        viewModel.bookings.observe(viewLifecycleOwner) { bookings ->
            currentBookings = bookings
            val names = bookings.map { "${it.guestName} - ${it.roomNumber}" }
            val adapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, names)
            binding.bookingAutoComplete.setAdapter(adapter)
            binding.bookingAutoComplete.setOnItemClickListener { _, _, position, _ ->
                selectedBookingId = currentBookings.getOrNull(position)?.id
            }
        }

        val methodOptions = listOf(
            getString(com.hotel.management.R.string.label_payment_cash),
            getString(com.hotel.management.R.string.label_payment_card),
            getString(com.hotel.management.R.string.label_payment_transfer)
        )
        val methodAdapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, methodOptions)
        binding.methodInput.setAdapter(methodAdapter)

        val revenueOptions = listOf(
            getString(com.hotel.management.R.string.label_rooms),
            getString(com.hotel.management.R.string.label_revenue_restaurant),
            getString(com.hotel.management.R.string.label_revenue_services),
            getString(com.hotel.management.R.string.label_other)
        )
        val revenueAdapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, revenueOptions)
        binding.revenueTypeInput.setAdapter(revenueAdapter)

        binding.saveButton.setOnClickListener { savePayment() }
        binding.cancelButton.setOnClickListener { findNavController().navigateUp() }

        viewModel.saveState.observe(viewLifecycleOwner) { state ->
            when (state) {
                is Result.Success -> findNavController().navigateUp()
                is Result.Loading -> binding.progressBar.visibility = View.VISIBLE
                is Result.Error -> binding.progressBar.visibility = View.GONE
            }
        }
    }

    private fun savePayment() {
        val amount = binding.amountInput.text?.toString()?.toDoubleOrNull() ?: 0.0
        val method = binding.methodInput.text?.toString().orEmpty()
        val normalizedMethod = when (method) {
            getString(com.hotel.management.R.string.label_payment_cash) -> "cash"
            getString(com.hotel.management.R.string.label_payment_card) -> "card"
            getString(com.hotel.management.R.string.label_payment_transfer) -> "transfer"
            else -> method.lowercase()
        }
        val revenue = binding.revenueTypeInput.text?.toString().orEmpty()
        val normalizedRevenue = when (revenue) {
            getString(com.hotel.management.R.string.label_rooms) -> "room"
            getString(com.hotel.management.R.string.label_revenue_restaurant) -> "restaurant"
            getString(com.hotel.management.R.string.label_revenue_services) -> "services"
            else -> "other"
        }
        val notes = binding.notesInput.text?.toString()
        val bookingId = selectedBookingId ?: return
        val payment = PaymentEntity(
            bookingId = bookingId,
            amount = amount,
            paymentMethod = normalizedMethod,
            revenueType = normalizedRevenue,
            notes = notes,
            paymentDate = LocalDate.now()
        )
        viewModel.savePayment(payment)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
