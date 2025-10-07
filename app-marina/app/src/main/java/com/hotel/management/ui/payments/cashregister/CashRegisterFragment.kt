package com.hotel.management.ui.payments.cashregister

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.hotel.management.HotelManagementApp
import com.hotel.management.adapters.CashTransactionsAdapter
import com.hotel.management.databinding.FragmentCashRegisterBinding
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.CashRegisterViewModel
import java.time.Instant

class CashRegisterFragment : Fragment() {

    private var _binding: FragmentCashRegisterBinding? = null
    private val binding get() = _binding!!

    private val viewModel: CashRegisterViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    private val adapter = CashTransactionsAdapter()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentCashRegisterBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL
        binding.transactionsList.adapter = adapter

        binding.openRegisterButton.setOnClickListener {
            val register = CashRegisterEntity(
                openingBalance = binding.openingBalanceInput.text?.toString()?.toDoubleOrNull() ?: 0.0,
                status = "open",
                openedBy = "",
                openedAt = Instant.now()
            )
            viewModel.openRegister(register)
        }

        binding.addTransactionButton.setOnClickListener {
            val latest = viewModel.latestRegister.value ?: return@setOnClickListener
            val transaction = CashTransactionEntity(
                registerId = latest.id,
                type = binding.transactionTypeInput.text?.toString().orEmpty(),
                amount = binding.transactionAmountInput.text?.toString()?.toDoubleOrNull() ?: 0.0,
                description = binding.transactionDescriptionInput.text?.toString()
            )
            viewModel.addTransaction(transaction)
        }

        viewModel.latestRegister.observe(viewLifecycleOwner) { register ->
            if (register != null) {
                renderRegister(register)
                viewModel.registerTransactions(register.id).observe(viewLifecycleOwner) { transactions ->
                    adapter.submitList(transactions)
                }
            }
        }
    }

    private fun renderRegister(register: CashRegisterEntity) {
        binding.openingBalanceValue.text = register.openingBalance.toString()
        binding.totalIncomeValue.text = register.totalIncome.toString()
        binding.totalExpenseValue.text = register.totalExpense.toString()
        val balance = register.closingBalance ?: register.openingBalance + register.totalIncome - register.totalExpense
        binding.currentBalanceValue.text = balance.toString()
        binding.registerStatusValue.text = register.status
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
