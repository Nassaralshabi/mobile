package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.R
import com.hotel.management.databinding.ItemEmployeeBinding
import com.hotel.management.models.EmployeeEntity

class EmployeesAdapter(private val onEmployeeClick: (EmployeeEntity) -> Unit) :
    ListAdapter<EmployeeEntity, EmployeesAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemEmployeeBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemEmployeeBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: EmployeeEntity) {
            binding.employeeName.text = item.name
            binding.employeeRole.text = item.position
            binding.employeeSalary.text = item.basicSalary.toString()
            val statusColor = when (item.status) {
                "active" -> R.drawable.bg_status_available
                "inactive" -> R.drawable.bg_status_neutral
                else -> R.drawable.bg_status_occupied
            }
            binding.employeeStatus.text = item.status
            binding.employeeStatus.background = ContextCompat.getDrawable(binding.root.context, statusColor)
            binding.root.setOnClickListener { onEmployeeClick(item) }
        }
    }

    companion object Diff : DiffUtil.ItemCallback<EmployeeEntity>() {
        override fun areItemsTheSame(oldItem: EmployeeEntity, newItem: EmployeeEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: EmployeeEntity, newItem: EmployeeEntity): Boolean = oldItem == newItem
    }
}
