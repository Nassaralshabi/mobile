package com.hotel.management.ui.payments.list

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.datepicker.MaterialDatePicker
import com.hotel.management.HotelManagementApp
import com.hotel.management.R
import com.hotel.management.adapters.PaymentsAdapter
import com.hotel.management.databinding.FragmentPaymentsBinding
import com.hotel.management.viewmodel.AddPaymentViewModel
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.PaymentsViewModel
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

class PaymentsFragment : Fragment() {

    private var _binding: FragmentPaymentsBinding? = null
    private val binding get() = _binding!!

    private val paymentsViewModel: PaymentsViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private val addPaymentViewModel: AddPaymentViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private lateinit var adapter: PaymentsAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentPaymentsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        adapter = PaymentsAdapter { }
        binding.paymentsList.adapter = adapter

        binding.filterMethodGroup.setOnCheckedStateChangeListener { group, checkedIds ->
            val id = checkedIds.firstOrNull()
            val chip = id?.let { group.findViewById<com.google.android.material.chip.Chip>(it) }
            paymentsViewModel.setMethodFilter(chip?.tag?.toString())
        }

        binding.filterRevenueGroup.setOnCheckedStateChangeListener { group, checkedIds ->
            val id = checkedIds.firstOrNull()
            val chip = id?.let { group.findViewById<com.google.android.material.chip.Chip>(it) }
            paymentsViewModel.setRevenueFilter(chip?.tag?.toString())
        }

        binding.filterDateButton.setOnClickListener { showDateRangePicker() }

        binding.addPaymentFab.setOnClickListener {
            findNavController().navigate(R.id.action_payments_to_add_payment)
        }

        binding.openCashRegister.setOnClickListener {
            findNavController().navigate(R.id.action_payments_to_cash_register)
        }

        binding.openInvoices.setOnClickListener {
            findNavController().navigate(R.id.action_payments_to_invoices)
        }

        paymentsViewModel.payments.observe(viewLifecycleOwner) { payments ->
            binding.emptyState.visibility = if (payments.isEmpty()) View.VISIBLE else View.GONE
            adapter.submitList(payments)
        }
    }

    private fun showDateRangePicker() {
        val picker = MaterialDatePicker.Builder.dateRangePicker().build()
        picker.addOnPositiveButtonClickListener { range ->
            val start = range.first?.let { Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).toLocalDate() }
            val end = range.second?.let { Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).toLocalDate() }
            paymentsViewModel.setDateRange(start, end)
        }
        picker.show(childFragmentManager, "payments_range")
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
