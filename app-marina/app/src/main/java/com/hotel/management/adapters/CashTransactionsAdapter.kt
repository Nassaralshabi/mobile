package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemCashTransactionBinding
import com.hotel.management.models.CashTransactionEntity

class CashTransactionsAdapter :
    ListAdapter<CashTransactionEntity, CashTransactionsAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemCashTransactionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemCashTransactionBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: CashTransactionEntity) {
            binding.transactionType.text = item.type
            binding.transactionAmount.text = item.amount.toString()
            binding.transactionDescription.text = item.description ?: ""
            binding.transactionDate.text = item.createdAt.toString()
        }
    }

    companion object Diff : DiffUtil.ItemCallback<CashTransactionEntity>() {
        override fun areItemsTheSame(oldItem: CashTransactionEntity, newItem: CashTransactionEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: CashTransactionEntity, newItem: CashTransactionEntity): Boolean = oldItem == newItem
    }
}
