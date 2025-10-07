package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemExpenseBinding
import com.hotel.management.models.ExpenseEntity

class ExpensesAdapter(private val onExpenseClick: (ExpenseEntity) -> Unit) :
    ListAdapter<ExpenseEntity, ExpensesAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemExpenseBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemExpenseBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: ExpenseEntity) {
            binding.expenseCategory.text = item.category
            binding.expenseAmount.text = item.amount.toString()
            binding.expenseDate.text = item.expenseDate.toString()
            binding.expenseSupplier.text = item.supplierId?.toString() ?: ""
            binding.root.setOnClickListener { onExpenseClick(item) }
        }
    }

    companion object Diff : DiffUtil.ItemCallback<ExpenseEntity>() {
        override fun areItemsTheSame(oldItem: ExpenseEntity, newItem: ExpenseEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: ExpenseEntity, newItem: ExpenseEntity): Boolean = oldItem == newItem
    }
}
