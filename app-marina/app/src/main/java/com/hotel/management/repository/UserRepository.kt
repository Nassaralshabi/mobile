package com.hotel.management.repository

import com.hotel.management.database.dao.UserDao
import com.hotel.management.models.UserEntity
import com.hotel.management.utils.SecurityUtils

class UserRepository(private val userDao: UserDao) {

    suspend fun authenticate(username: String, password: String): Boolean {
        val user = userDao.findByUsername(username) ?: return false
        return SecurityUtils.verifyPassword(password, user.salt, user.passwordHash)
    }

    suspend fun createUser(username: String, password: String, role: String, displayName: String): Long {
        val salt = SecurityUtils.generateSalt()
        val hash = SecurityUtils.hashPassword(password, salt)
        val entity = UserEntity(
            username = username,
            passwordHash = hash,
            salt = salt,
            role = role,
            displayName = displayName
        )
        return userDao.upsert(entity)
    }

    suspend fun updatePassword(userId: Long, newPassword: String) {
        val user = userDao.findById(userId) ?: return
        val salt = SecurityUtils.generateSalt()
        val hash = SecurityUtils.hashPassword(newPassword, salt)
        val updated = user.copy(passwordHash = hash, salt = salt)
        userDao.update(updated)
    }

    suspend fun updateUser(user: UserEntity) {
        userDao.update(user)
    }

    fun observeUsers() = userDao.observeUsers()
}
