package com.hotel.management.ui.expenses.list

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.google.android.material.chip.Chip
import com.hotel.management.HotelManagementApp
import com.hotel.management.R
import com.hotel.management.adapters.ExpensesAdapter
import com.hotel.management.databinding.FragmentExpensesBinding
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.ExpensesViewModel

class ExpensesFragment : Fragment() {

    private var _binding: FragmentExpensesBinding? = null
    private val binding get() = _binding!!

    private val viewModel: ExpensesViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private lateinit var adapter: ExpensesAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentExpensesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        adapter = ExpensesAdapter { }
        binding.expensesList.adapter = adapter

        binding.categoryFilterGroup.setOnCheckedStateChangeListener { group, checkedIds ->
            val id = checkedIds.firstOrNull()
            val chip = id?.let { group.findViewById<Chip>(it) }
            viewModel.setCategoryFilter(chip?.tag?.toString())
        }

        binding.addExpenseFab.setOnClickListener {
            findNavController().navigate(R.id.action_expenses_to_add_expense)
        }

        viewModel.expenses.observe(viewLifecycleOwner) { expenses ->
            adapter.submitList(expenses)
            binding.emptyState.visibility = if (expenses.isEmpty()) View.VISIBLE else View.GONE
        }

        viewModel.suppliers.observe(viewLifecycleOwner) { suppliers ->
            val adapterSuppliers = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, suppliers.map { it.name })
            binding.supplierAutoComplete.setAdapter(adapterSuppliers)
            binding.supplierAutoComplete.setOnItemClickListener { _, _, position, _ ->
                viewModel.setSupplierFilter(suppliers[position].id)
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
