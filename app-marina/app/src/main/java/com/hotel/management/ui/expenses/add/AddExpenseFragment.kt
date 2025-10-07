package com.hotel.management.ui.expenses.add

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.hotel.management.HotelManagementApp
import com.hotel.management.databinding.FragmentAddExpenseBinding
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.SupplierEntity
import com.hotel.management.utils.Result
import com.hotel.management.viewmodel.AddExpenseViewModel
import com.hotel.management.viewmodel.AppViewModelFactory
import java.time.LocalDate

class AddExpenseFragment : Fragment() {

    private var _binding: FragmentAddExpenseBinding? = null
    private val binding get() = _binding!!

    private val viewModel: AddExpenseViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private var selectedSupplierId: Long? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentAddExpenseBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        viewModel.suppliers.observe(viewLifecycleOwner) { suppliers ->
            val adapter = android.widget.ArrayAdapter(requireContext(), android.R.layout.simple_list_item_1, suppliers.map { it.name })
            binding.supplierAutoComplete.setAdapter(adapter)
            binding.supplierAutoComplete.setOnItemClickListener { _, _, position, _ ->
                selectedSupplierId = suppliers[position].id
            }
        }

        binding.saveButton.setOnClickListener { saveExpense() }
        binding.cancelButton.setOnClickListener { findNavController().navigateUp() }

        binding.addSupplierButton.setOnClickListener {
            val name = binding.newSupplierNameInput.text?.toString().orEmpty()
            if (name.isNotEmpty()) {
                val supplier = SupplierEntity(name = name)
                viewModel.saveSupplier(supplier)
                binding.newSupplierNameInput.setText("")
            }
        }

        viewModel.saveState.observe(viewLifecycleOwner) { state ->
            when (state) {
                is Result.Success -> findNavController().navigateUp()
                is Result.Loading -> binding.progressBar.visibility = View.VISIBLE
                is Result.Error -> binding.progressBar.visibility = View.GONE
            }
        }
    }

    private fun saveExpense() {
        val expense = ExpenseEntity(
            category = binding.categoryInput.text?.toString().orEmpty(),
            description = binding.descriptionInput.text?.toString().orEmpty(),
            amount = binding.amountInput.text?.toString()?.toDoubleOrNull() ?: 0.0,
            supplierId = selectedSupplierId,
            expenseDate = LocalDate.now(),
            addedBy = ""
        )
        viewModel.saveExpense(expense)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
