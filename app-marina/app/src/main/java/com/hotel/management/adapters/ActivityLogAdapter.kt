package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemActivityLogBinding
import com.hotel.management.models.ActivityLogItem

class ActivityLogAdapter : ListAdapter<ActivityLogItem, ActivityLogAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemActivityLogBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemActivityLogBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: ActivityLogItem) {
            binding.logUser.text = item.userName
            binding.logAction.text = item.actionType
            binding.logDescription.text = item.description
            binding.logTime.text = item.createdAt.toString()
        }
    }

    companion object Diff : DiffUtil.ItemCallback<ActivityLogItem>() {
        override fun areItemsTheSame(oldItem: ActivityLogItem, newItem: ActivityLogItem): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: ActivityLogItem, newItem: ActivityLogItem): Boolean = oldItem == newItem
    }
}
