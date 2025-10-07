package com.hotel.management.ui.settings.activitylog

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.hotel.management.adapters.ActivityLogAdapter
import com.hotel.management.databinding.FragmentActivityLogBinding
import com.hotel.management.models.ActivityLogItem
import com.hotel.management.viewmodel.ActivityLogViewModel
import java.time.Instant

class ActivityLogFragment : Fragment() {

    private var _binding: FragmentActivityLogBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ActivityLogViewModel by activityViewModels()
    private val adapter = ActivityLogAdapter()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentActivityLogBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL
        binding.activityLogList.adapter = adapter

        viewModel.logs.observe(viewLifecycleOwner) { logs ->
            adapter.submitList(logs)
            binding.emptyState.visibility = if (logs.isEmpty()) View.VISIBLE else View.GONE
        }

        if (viewModel.logs.value.isNullOrEmpty()) {
            val sample = listOf(
                ActivityLogItem(1, "admin", "login", "Login successful", Instant.now()),
                ActivityLogItem(2, "manager", "booking", "Created booking #122", Instant.now())
            )
            viewModel.submitLogs(sample)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
