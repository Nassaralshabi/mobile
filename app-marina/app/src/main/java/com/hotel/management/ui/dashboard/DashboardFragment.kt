package com.hotel.management.ui.dashboard

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.hotel.management.HotelManagementApp
import com.hotel.management.R
import com.hotel.management.databinding.FragmentDashboardBinding
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.DashboardViewModel

class DashboardFragment : Fragment() {

    private var _binding: FragmentDashboardBinding? = null
    private val binding get() = _binding!!

    private val viewModel: DashboardViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentDashboardBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        binding.cardBookings.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_bookings)
        }
        binding.cardRooms.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_rooms)
        }
        binding.cardPayments.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_payments)
        }
        binding.cardCashRegister.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_cash_register)
        }
        binding.cardExpenses.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_expenses)
        }
        binding.cardEmployees.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_employees)
        }
        binding.cardInvoices.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_invoices)
        }
        binding.cardReports.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_reports)
        }
        binding.cardSettings.setOnClickListener {
            findNavController().navigate(R.id.action_dashboard_to_settings)
        }

        viewModel.metrics.observe(viewLifecycleOwner) { metrics ->
            binding.availableRoomsValue.text = metrics.availableRooms.toString()
            binding.occupiedRoomsValue.text = metrics.occupiedRooms.toString()
            binding.maintenanceRoomsValue.text = metrics.maintenanceRooms.toString()
            binding.currentGuestsValue.text = metrics.currentGuests.toString()
            binding.dailyRevenueValue.text = metrics.dailyRevenue.toString()
            binding.cashBalanceValue.text = metrics.cashBalance.toString()
            binding.highAlertsValue.text = metrics.highPriorityAlerts.toString()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
