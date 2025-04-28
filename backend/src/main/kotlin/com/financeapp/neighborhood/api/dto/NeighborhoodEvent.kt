package com.financeapp.neighborhood.api.dto

data class NeighborhoodEvent(
    val type: String, // e.g., "NEW_POST", "NEW_COMMENT"
    val payload: Any
)
