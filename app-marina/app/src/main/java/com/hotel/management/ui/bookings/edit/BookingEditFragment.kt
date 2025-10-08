package com.hotel.management.ui.bookings.edit

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.google.android.material.datepicker.MaterialDatePicker
import com.hotel.management.HotelManagementApp
import com.hotel.management.databinding.FragmentBookingEditBinding
import com.hotel.management.models.BookingEntity
import com.hotel.management.utils.BookingConstants.NEW_BOOKING_ID
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.BookingEditViewModel
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

class BookingEditFragment : Fragment() {

    private var _binding: FragmentBookingEditBinding? = null
    private val binding get() = _binding!!
    private val args: BookingEditFragmentArgs by navArgs()

    private val viewModel: BookingEditViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private var checkInDate: LocalDate = LocalDate.now()
    private var checkOutDate: LocalDate = LocalDate.now().plusDays(1)

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBookingEditBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        binding.checkInField.setOnClickListener { showDatePicker(true) }
        binding.checkOutField.setOnClickListener { showDatePicker(false) }

        binding.saveButton.setOnClickListener {
            val booking = collectBooking()
            viewModel.saveBooking(booking)
        }
        binding.cancelButton.setOnClickListener { findNavController().navigateUp() }

        viewModel.saveState.observe(viewLifecycleOwner) { result ->
            if (result is com.hotel.management.utils.Result.Success) {
                findNavController().navigateUp()
            }
        }

        viewModel.rooms.observe(viewLifecycleOwner) { rooms ->
            val adapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, rooms.map { it.roomNumber })
            binding.roomAutoComplete.setAdapter(adapter)
        }

        viewModel.editingBooking.observe(viewLifecycleOwner) { booking ->
            booking?.let { populateForm(it) }
        }

        if (args.bookingId != NEW_BOOKING_ID) {
            viewModel.loadBooking(args.bookingId)
        } else {
            updateDateFields()
        }
    }

    private fun showDatePicker(isCheckIn: Boolean) {
        val picker = MaterialDatePicker.Builder.datePicker().build()
        picker.addOnPositiveButtonClickListener { selection ->
            val date = Instant.ofEpochMilli(selection).atZone(ZoneId.systemDefault()).toLocalDate()
            if (isCheckIn) {
                checkInDate = date
            } else {
                checkOutDate = date
            }
            updateDateFields()
        }
        picker.show(childFragmentManager, if (isCheckIn) "check_in" else "check_out")
    }

    private fun updateDateFields() {
        binding.checkInField.text = checkInDate.toString()
        binding.checkOutField.text = checkOutDate.toString()
        val nights = viewModel.calculateNights(checkInDate, checkOutDate)
        binding.nightsValue.text = nights.toString()
    }

    private fun populateForm(booking: BookingEntity) {
        binding.guestNameInput.setText(booking.guestName)
        binding.guestPhoneInput.setText(booking.guestPhone)
        binding.guestEmailInput.setText(booking.guestEmail)
        binding.statusInput.setText(booking.status)
        binding.notesInput.setText(booking.notes)
        checkInDate = booking.checkInDate
        checkOutDate = booking.checkOutDate
        updateDateFields()
    }

    private fun collectBooking(): BookingEntity {
        val roomNumber = binding.roomAutoComplete.text?.toString()?.toIntOrNull() ?: 0
        return BookingEntity(
            id = args.bookingId,
            guestName = binding.guestNameInput.text?.toString().orEmpty(),
            guestPhone = binding.guestPhoneInput.text?.toString().orEmpty(),
            guestEmail = binding.guestEmailInput.text?.toString().orEmpty(),
            roomNumber = roomNumber,
            checkInDate = checkInDate,
            checkOutDate = checkOutDate,
            status = binding.statusInput.text?.toString().orEmpty(),
            notes = binding.notesInput.text?.toString(),
            totalAmount = binding.totalAmountInput.text?.toString()?.toDoubleOrNull() ?: 0.0,
            paidAmount = binding.paidAmountInput.text?.toString()?.toDoubleOrNull() ?: 0.0
        )
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
