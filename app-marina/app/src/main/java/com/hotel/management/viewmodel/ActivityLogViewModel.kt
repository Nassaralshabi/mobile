package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.hotel.management.models.ActivityLogItem

class ActivityLogViewModel : ViewModel() {

    private val _logs = MutableLiveData<List<ActivityLogItem>>(emptyList())
    val logs: LiveData<List<ActivityLogItem>> = _logs

    fun submitLogs(items: List<ActivityLogItem>) {
        _logs.value = items
    }
}
