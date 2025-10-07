package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemPaymentBinding
import com.hotel.management.models.PaymentEntity

class PaymentsAdapter(private val onPaymentClick: (PaymentEntity) -> Unit) :
    ListAdapter<PaymentEntity, PaymentsAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemPaymentBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemPaymentBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: PaymentEntity) {
            binding.paymentAmount.text = item.amount.toString()
            binding.paymentMethod.text = item.paymentMethod
            binding.paymentRevenueType.text = item.revenueType
            binding.paymentDate.text = item.paymentDate.toString()
            binding.root.setOnClickListener { onPaymentClick(item) }
        }
    }

    companion object Diff : DiffUtil.ItemCallback<PaymentEntity>() {
        override fun areItemsTheSame(oldItem: PaymentEntity, newItem: PaymentEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: PaymentEntity, newItem: PaymentEntity): Boolean = oldItem == newItem
    }
}
