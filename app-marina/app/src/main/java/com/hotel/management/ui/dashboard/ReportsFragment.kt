package com.hotel.management.ui.dashboard

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.google.android.material.datepicker.MaterialDatePicker
import com.hotel.management.HotelManagementApp
import com.hotel.management.databinding.FragmentReportsBinding
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.ReportsViewModel
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

class ReportsFragment : Fragment() {

    private var _binding: FragmentReportsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ReportsViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentReportsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        binding.selectDateRange.setOnClickListener {
            val picker = MaterialDatePicker.Builder.dateRangePicker().build()
            picker.addOnPositiveButtonClickListener { range ->
                val start = range.first?.let { Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).toLocalDate() }
                val end = range.second?.let { Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).toLocalDate() }
                viewModel.setDateRange(start, end)
            }
            picker.show(childFragmentManager, "reports_range")
        }

        viewModel.reportSummary.observe(viewLifecycleOwner) { summary ->
            binding.dailyRevenueSummary.text = summary.revenueByDay.entries.joinToString("\n") { "${it.key}: ${it.value}" }
            binding.monthlyRevenueSummary.text = summary.revenueByMonth.entries.joinToString("\n") { "${it.key}: ${it.value}" }
            binding.occupancyValue.text = summary.occupancyRate.toString()
            binding.expenseSummary.text = summary.expenseTotals.entries.joinToString("\n") { "${it.key}: ${it.value}" }
            binding.paymentMethodSummary.text = summary.paymentMethodBreakdown.entries.joinToString("\n") { "${it.key}: ${it.value}" }
            binding.cashRegisterSummary.text = summary.cashRegisterTotals.entries.joinToString("\n") { "${it.key}: ${it.value}" }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
