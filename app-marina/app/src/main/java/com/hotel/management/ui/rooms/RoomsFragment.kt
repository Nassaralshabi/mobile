package com.hotel.management.ui.rooms

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.google.android.material.chip.Chip
import com.hotel.management.HotelManagementApp
import com.hotel.management.adapters.RoomsAdapter
import com.hotel.management.databinding.FragmentRoomsBinding
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.RoomsViewModel

class RoomsFragment : Fragment() {

    private var _binding: FragmentRoomsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: RoomsViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private lateinit var adapter: RoomsAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentRoomsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        adapter = RoomsAdapter { }
        binding.roomsGrid.adapter = adapter

        binding.statusChips.setOnCheckedStateChangeListener { group, checked ->
            val selectedId = checked.firstOrNull()
            val chip = selectedId?.let { group.findViewById<Chip>(it) }
            viewModel.setStatusFilter(chip?.tag?.toString())
        }

        binding.typeInput.doAfterTextChanged { text ->
            viewModel.setTypeFilter(text?.toString())
        }

        viewModel.rooms.observe(viewLifecycleOwner) { rooms ->
            binding.emptyState.visibility = if (rooms.isEmpty()) View.VISIBLE else View.GONE
            adapter.submitList(rooms)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
