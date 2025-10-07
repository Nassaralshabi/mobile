package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.R
import com.hotel.management.databinding.ItemRoomBinding
import com.hotel.management.models.RoomEntity

class RoomsAdapter(private val onRoomClick: (RoomEntity) -> Unit) :
    ListAdapter<RoomEntity, RoomsAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        val binding = ItemRoomBinding.inflate(inflater, parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemRoomBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: RoomEntity) {
            binding.roomNumber.text = item.roomNumber
            binding.roomType.text = item.roomType
            binding.roomPrice.text = item.pricePerNight.toString()
            val context = binding.root.context
            val background = when (item.status) {
                "available" -> R.drawable.bg_status_available
                "occupied" -> R.drawable.bg_status_occupied
                "maintenance" -> R.drawable.bg_status_maintenance
                else -> R.drawable.bg_status_neutral
            }
            binding.roomStatus.text = item.status
            binding.roomStatus.background = ContextCompat.getDrawable(context, background)
            binding.root.setOnClickListener { onRoomClick(item) }
        }
    }

    companion object Diff : DiffUtil.ItemCallback<RoomEntity>() {
        override fun areItemsTheSame(oldItem: RoomEntity, newItem: RoomEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: RoomEntity, newItem: RoomEntity): Boolean = oldItem == newItem
    }
}
