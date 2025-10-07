package com.hotel.management.ui.payments.invoices

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.hotel.management.HotelManagementApp
import com.hotel.management.adapters.InvoicesAdapter
import com.hotel.management.databinding.FragmentInvoicesBinding
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.InvoicesViewModel

class InvoicesFragment : Fragment() {

    private var _binding: FragmentInvoicesBinding? = null
    private val binding get() = _binding!!

    private val viewModel: InvoicesViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private lateinit var adapter: InvoicesAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentInvoicesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        adapter = InvoicesAdapter(onInvoiceClick = { }, onExportClick = { })
        binding.invoicesList.adapter = adapter

        binding.statusFilterGroup.setOnCheckedStateChangeListener { group, checkedIds ->
            val id = checkedIds.firstOrNull()
            val chip = id?.let { group.findViewById<com.google.android.material.chip.Chip>(it) }
            viewModel.setStatusFilter(chip?.tag?.toString())
        }

        viewModel.invoices.observe(viewLifecycleOwner) { invoices ->
            adapter.submitList(invoices)
            binding.emptyState.visibility = if (invoices.isEmpty()) View.VISIBLE else View.GONE
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
