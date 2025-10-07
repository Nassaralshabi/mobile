package com.hotel.management.ui.bookings.list

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.chip.Chip
import com.hotel.management.HotelManagementApp
import com.hotel.management.R
import com.hotel.management.adapters.BookingsAdapter
import com.hotel.management.databinding.FragmentBookingsBinding
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.BookingsViewModel

class BookingsFragment : Fragment() {

    private var _binding: FragmentBookingsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: BookingsViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private lateinit var adapter: BookingsAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentBookingsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        adapter = BookingsAdapter(
            onBookingClick = {
                val action = BookingsFragmentDirections.actionBookingsToBookingDetails(it.booking.id)
                findNavController().navigate(action)
            },
            onEditClick = {
                val action = BookingsFragmentDirections.actionBookingsToBookingEdit(it.booking.id)
                findNavController().navigate(action)
            },
            onAddNoteClick = {
                val action = BookingsFragmentDirections.actionBookingsToBookingDetails(it.booking.id)
                findNavController().navigate(action)
            }
        )
        binding.bookingsList.adapter = adapter

        binding.searchInput.doAfterTextChanged { text ->
            viewModel.updateSearch(text?.toString().orEmpty())
        }

        binding.filterChipGroup.setOnCheckedStateChangeListener { group, checkedIds ->
            val selectedId = checkedIds.firstOrNull()
            val selectedChip = selectedId?.let { group.findViewById<Chip>(it) }
            viewModel.applyFilter(selectedChip?.tag?.toString())
        }

        binding.addBookingFab.setOnClickListener {
            val action = BookingsFragmentDirections.actionBookingsToBookingEdit(0L)
            findNavController().navigate(action)
        }

        viewModel.bookings.observe(viewLifecycleOwner) { bookings ->
            binding.emptyState.visibility = if (bookings.isEmpty()) View.VISIBLE else View.GONE
            adapter.submitList(bookings)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
