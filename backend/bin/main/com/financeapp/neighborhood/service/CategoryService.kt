package com.financeapp.neighborhood.service

import com.financeapp.neighborhood.api.dto.CategoryDTO
import com.financeapp.neighborhood.domain.repository.CategoryRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class CategoryService(
    private val categoryRepository: CategoryRepository
) {

    @Transactional(readOnly = true)
    fun getAllCategories(): List<CategoryDTO> {
        return categoryRepository.findAll().map { CategoryDTO.fromEntity(it) }
    }
} 