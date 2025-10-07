package com.hotel.management.ui.settings.employees

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.hotel.management.HotelManagementApp
import com.hotel.management.adapters.EmployeesAdapter
import com.hotel.management.databinding.FragmentEmployeesBinding
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.models.EmployeeEntity
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.EmployeesViewModel

class EmployeesFragment : Fragment() {

    private var _binding: FragmentEmployeesBinding? = null
    private val binding get() = _binding!!

    private val viewModel: EmployeesViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private lateinit var adapter: EmployeesAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentEmployeesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        adapter = EmployeesAdapter { employee -> showEmployeeDetails(employee) }
        binding.employeesList.adapter = adapter

        viewModel.employees.observe(viewLifecycleOwner) { employees ->
            adapter.submitList(employees)
            binding.emptyState.visibility = if (employees.isEmpty()) View.VISIBLE else View.GONE
        }
    }

    private fun showEmployeeDetails(employee: EmployeeEntity) {
        val liveData = viewModel.withdrawals(employee.id)
        val observer = object : androidx.lifecycle.Observer<List<CashTransactionEntity>> {
            override fun onChanged(withdrawals: List<CashTransactionEntity>) {
                val history = withdrawals.joinToString("\n") { formatWithdrawal(it) }
                MaterialAlertDialogBuilder(requireContext())
                    .setTitle(employee.name)
                    .setMessage(history.ifEmpty { "" })
                    .setPositiveButton(android.R.string.ok, null)
                    .show()
                liveData.removeObserver(this)
            }
        }
        liveData.observe(viewLifecycleOwner, observer)
    }

    private fun formatWithdrawal(transaction: CashTransactionEntity): String {
        return "${transaction.createdAt}: ${transaction.amount}"
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
