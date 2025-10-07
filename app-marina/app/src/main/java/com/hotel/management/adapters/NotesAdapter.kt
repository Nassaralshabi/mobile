package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemBookingNoteBinding
import com.hotel.management.models.BookingNoteEntity

class NotesAdapter : ListAdapter<BookingNoteEntity, NotesAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemBookingNoteBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemBookingNoteBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: BookingNoteEntity) {
            binding.noteText.text = item.note
            binding.notePriority.text = item.alertType
            binding.noteExpiry.text = item.alertUntil?.toString() ?: ""
        }
    }

    companion object Diff : DiffUtil.ItemCallback<BookingNoteEntity>() {
        override fun areItemsTheSame(oldItem: BookingNoteEntity, newItem: BookingNoteEntity): Boolean = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: BookingNoteEntity, newItem: BookingNoteEntity): Boolean = oldItem == newItem
    }
}
