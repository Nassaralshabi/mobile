package com.hotel.management.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.hotel.management.databinding.ItemBookingBinding
import com.hotel.management.models.relations.BookingWithNotes

class BookingsAdapter(
    private val onBookingClick: (BookingWithNotes) -> Unit,
    private val onEditClick: (BookingWithNotes) -> Unit,
    private val onAddNoteClick: (BookingWithNotes) -> Unit
) : ListAdapter<BookingWithNotes, BookingsAdapter.ViewHolder>(Diff) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        val binding = ItemBookingBinding.inflate(inflater, parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemBookingBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: BookingWithNotes) {
            binding.guestName.text = item.booking.guestName
            binding.bookingDates.text = "${item.booking.checkInDate} - ${item.booking.checkOutDate}"
            binding.bookingStatus.text = item.booking.status
            binding.bookingStatus.tag = item.booking.status
            binding.root.setOnClickListener { onBookingClick(item) }
            binding.editBooking.setOnClickListener { onEditClick(item) }
            binding.addNote.setOnClickListener { onAddNoteClick(item) }
            binding.alertBadge.text = item.notes.count { it.alertType == "high" }.toString()
        }
    }

    companion object Diff : DiffUtil.ItemCallback<BookingWithNotes>() {
        override fun areItemsTheSame(oldItem: BookingWithNotes, newItem: BookingWithNotes): Boolean = oldItem.booking.id == newItem.booking.id
        override fun areContentsTheSame(oldItem: BookingWithNotes, newItem: BookingWithNotes): Boolean = oldItem == newItem
    }
}
