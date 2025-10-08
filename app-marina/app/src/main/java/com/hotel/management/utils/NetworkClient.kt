package com.hotel.management.utils

import android.content.Context
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import java.util.concurrent.TimeUnit

object NetworkClient {

    private const val DEFAULT_BASE_URL = "https://example-hotel-api.com"

    private fun provideLoggingInterceptor(): Interceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private fun provideHeaderInterceptor(preferencesManager: PreferencesManager): Interceptor = Interceptor { chain ->
        val token = preferencesManager.authToken
        val request = chain.request()
            .newBuilder()
            .apply {
                if (!token.isNullOrBlank()) {
                    header("Authorization", "Bearer $token")
                }
                header("Accept-Language", "ar")
            }
            .build()
        chain.proceed(request)
    }

    fun createRetrofit(context: Context, preferencesManager: PreferencesManager, baseUrl: String = DEFAULT_BASE_URL): Retrofit {
        val normalisedBaseUrl = if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/"

        val client = OkHttpClient.Builder()
            .callTimeout(30, TimeUnit.SECONDS)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(provideHeaderInterceptor(preferencesManager))
            .addInterceptor(provideLoggingInterceptor())
            .build()

        return Retrofit.Builder()
            .baseUrl(normalisedBaseUrl)
            .client(client)
            .addConverterFactory(MoshiConverterFactory.create())
            .build()
    }
}
