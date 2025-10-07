package com.hotel.management.repository

import com.hotel.management.database.dao.RoomDao
import com.hotel.management.models.RoomEntity
import com.hotel.management.utils.HotelApiService
import kotlinx.coroutines.flow.Flow

class RoomRepository(
    private val roomDao: RoomDao,
    private val apiService: HotelApiService
) {

    fun observeRooms(): Flow<List<RoomEntity>> = roomDao.observeRooms()

    fun observeRoomsByStatus(status: String): Flow<List<RoomEntity>> = roomDao.observeRoomsByStatus(status)

    fun observeRoomsByType(type: String): Flow<List<RoomEntity>> = roomDao.observeRoomsByType(type)

    suspend fun saveRoom(room: RoomEntity): Long = roomDao.upsert(room)

    suspend fun removeRoom(room: RoomEntity) = roomDao.delete(room)

    suspend fun syncWithRemote() {
        try {
            val remoteRooms = apiService.fetchRooms()
            remoteRooms.forEach { roomDao.upsert(it) }
        } catch (_: Exception) {
        }
    }
}
