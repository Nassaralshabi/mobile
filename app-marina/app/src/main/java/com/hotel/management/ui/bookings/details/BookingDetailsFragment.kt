package com.hotel.management.ui.bookings.details

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.hotel.management.HotelManagementApp
import com.hotel.management.R
import com.hotel.management.adapters.NotesAdapter
import com.hotel.management.databinding.FragmentBookingDetailsBinding
import com.hotel.management.models.BookingNoteEntity
import com.hotel.management.utils.Result
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.BookingDetailsViewModel
import java.time.LocalDateTime

class BookingDetailsFragment : Fragment() {

    private var _binding: FragmentBookingDetailsBinding? = null
    private val binding get() = _binding!!
    private val args: BookingDetailsFragmentArgs by navArgs()

    private val viewModel: BookingDetailsViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private val notesAdapter = NotesAdapter()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBookingDetailsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL
        binding.notesList.adapter = notesAdapter

        val priorityLabels = listOf(
            getString(com.hotel.management.R.string.label_priority_high),
            getString(com.hotel.management.R.string.label_priority_medium),
            getString(com.hotel.management.R.string.label_priority_low)
        )
        val priorityValues = listOf("high", "medium", "low")
        val priorityAdapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, priorityLabels)
        binding.prioritySelector.setAdapter(priorityAdapter)
        binding.prioritySelector.tag = priorityValues.last()
        binding.prioritySelector.setText(priorityLabels.last(), false)
        binding.prioritySelector.setOnItemClickListener { _, _, position, _ ->
            binding.prioritySelector.tag = priorityValues[position]
        }

        binding.editBookingButton.setOnClickListener {
            val action = BookingDetailsFragmentDirections.actionBookingDetailsToBookingEdit(args.bookingId)
            findNavController().navigate(action)
        }
        binding.addNoteButton.setOnClickListener {
            val noteText = binding.noteInput.text?.toString().orEmpty()
            if (noteText.isNotEmpty()) {
                val note = BookingNoteEntity(
                    bookingId = args.bookingId,
                    note = noteText,
                    alertType = (binding.prioritySelector.tag as? String) ?: "low",
                    alertUntil = LocalDateTime.now().plusDays(1),
                    addedBy = ""
                )
                viewModel.addNote(note)
                binding.noteInput.setText("")
            }
        }

        binding.paymentsButton.setOnClickListener {
            findNavController().navigate(R.id.action_booking_details_to_payments)
        }

        viewModel.bookingDetails(args.bookingId).observe(viewLifecycleOwner) { result ->
            when (result) {
                is Result.Loading -> binding.loadingIndicator.visibility = View.VISIBLE
                is Result.Success -> {
                    binding.loadingIndicator.visibility = View.GONE
                    val booking = result.data?.booking
                    binding.guestName.text = booking?.guestName.orEmpty()
                    binding.guestPhone.text = booking?.guestPhone.orEmpty()
                    binding.guestEmail.text = booking?.guestEmail.orEmpty()
                    binding.bookingDates.text = "${booking?.checkInDate} - ${booking?.checkOutDate}"
                    binding.bookingStatus.text = booking?.status.orEmpty()
                    notesAdapter.submitList(result.data?.notes.orEmpty())
                }
                is Result.Error -> binding.loadingIndicator.visibility = View.GONE
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
