package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.RoomEntity
import com.hotel.management.repository.RoomRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class RoomsViewModel(private val roomRepository: RoomRepository) : ViewModel() {

    private val statusFilter = MutableStateFlow<String?>(null)
    private val typeFilter = MutableStateFlow<String?>(null)

    private val roomsFlow = roomRepository.observeRooms()

    private val filteredRooms = combine(roomsFlow, statusFilter, typeFilter) { rooms, status, type ->
        rooms.filter { room ->
            val statusMatches = status?.let { room.status == it } ?: true
            val typeMatches = type?.let { room.roomType == it } ?: true
            statusMatches && typeMatches
        }
    }.stateIn(viewModelScope, kotlinx.coroutines.flow.SharingStarted.WhileSubscribed(5_000), emptyList())

    val rooms: LiveData<List<RoomEntity>> = filteredRooms.asLiveData()

    fun setStatusFilter(status: String?) {
        statusFilter.value = status
    }

    fun setTypeFilter(type: String?) {
        typeFilter.value = type
    }

    fun updateRoom(room: RoomEntity) {
        viewModelScope.launch {
            roomRepository.saveRoom(room)
        }
    }
}
