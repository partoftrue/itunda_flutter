package com.financeapp.neighborhood.api.dto

import com.financeapp.neighborhood.domain.entity.Category
import java.time.LocalDateTime

data class CategoryDTO(
    val id: String,
    val name: String,
    val description: String?,
    val createdAt: LocalDateTime
) {
    companion object {
        fun fromEntity(category: Category): CategoryDTO {
            return CategoryDTO(
                id = category.id,
                name = category.name,
                description = category.description,
                createdAt = category.createdAt
            )
        }
    }
} 