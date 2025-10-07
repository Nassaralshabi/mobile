package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemInvoiceBinding
import com.hotel.management.models.InvoiceEntity

class InvoicesAdapter(
    private val onInvoiceClick: (InvoiceEntity) -> Unit,
    private val onExportClick: (InvoiceEntity) -> Unit
) : ListAdapter<InvoiceEntity, InvoicesAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemInvoiceBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemInvoiceBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: InvoiceEntity) {
            binding.invoiceNumber.text = item.invoiceNumber
            binding.invoiceTotal.text = item.totalAmount.toString()
            binding.invoiceStatus.text = item.status
            binding.invoiceDate.text = item.issuedAt.toString()
            binding.root.setOnClickListener { onInvoiceClick(item) }
            binding.exportInvoice.setOnClickListener { onExportClick(item) }
        }
    }

    companion object Diff : DiffUtil.ItemCallback<InvoiceEntity>() {
        override fun areItemsTheSame(oldItem: InvoiceEntity, newItem: InvoiceEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: InvoiceEntity, newItem: InvoiceEntity): Boolean = oldItem == newItem
    }
}
