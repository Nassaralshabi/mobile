package com.hotel.management.ui.settings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.hotel.management.HotelManagementApp
import com.hotel.management.R
import com.hotel.management.databinding.FragmentSettingsBinding
import com.hotel.management.utils.Result
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.SettingsViewModel

class SettingsFragment : Fragment() {

    private var _binding: FragmentSettingsBinding? = null
    private val binding get() = _binding!!

    private val viewModel: SettingsViewModel by activityViewModels {
        AppViewModelFactory(requireActivity().application as HotelManagementApp)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        _binding = FragmentSettingsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.layoutDirection = View.LAYOUT_DIRECTION_RTL

        binding.activityLogButton.setOnClickListener {
            findNavController().navigate(R.id.action_settings_to_activity_log)
        }
        binding.rememberUserSwitch.isChecked = viewModel.rememberUser
        binding.rememberUserSwitch.setOnCheckedChangeListener { _, isChecked ->
            viewModel.toggleRememberUser(isChecked)
        }

        binding.changePasswordButton.setOnClickListener {
            val userId = binding.userIdInput.text?.toString()?.toLongOrNull() ?: return@setOnClickListener
            val newPassword = binding.newPasswordInput.text?.toString().orEmpty()
            viewModel.changePassword(userId, newPassword)
        }

        binding.logoutButton.setOnClickListener {
            viewModel.logout()
            startActivity(android.content.Intent(requireContext(), com.hotel.management.ui.auth.LoginActivity::class.java))
            requireActivity().finish()
        }

        viewModel.users.observe(viewLifecycleOwner) { users ->
            binding.userList.text = users.joinToString("\n") { it.username }
        }

        viewModel.passwordChangeState.observe(viewLifecycleOwner) { state ->
            if (state is Result.Success) {
                binding.newPasswordInput.setText("")
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
