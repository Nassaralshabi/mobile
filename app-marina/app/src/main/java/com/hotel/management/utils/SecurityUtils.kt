package com.hotel.management.utils

import android.util.Base64
import java.security.MessageDigest
import java.security.SecureRandom

object SecurityUtils {

    private const val SALT_LENGTH = 16

    fun generateSalt(): String {
        val salt = ByteArray(SALT_LENGTH)
        SecureRandom().nextBytes(salt)
        return Base64.encodeToString(salt, Base64.NO_WRAP)
    }

    fun hashPassword(password: String, salt: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val saltBytes = Base64.decode(salt, Base64.NO_WRAP)
        digest.update(saltBytes)
        val hash = digest.digest(password.toByteArray())
        return Base64.encodeToString(hash, Base64.NO_WRAP)
    }

    fun verifyPassword(password: String, salt: String, hash: String): Boolean {
        val calculated = hashPassword(password, salt)
        return MessageDigest.isEqual(calculated.toByteArray(), hash.toByteArray())
    }
}
