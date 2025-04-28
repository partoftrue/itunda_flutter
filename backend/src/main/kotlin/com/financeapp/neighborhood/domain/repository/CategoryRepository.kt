package com.financeapp.neighborhood.domain.repository

import com.financeapp.neighborhood.domain.entity.Category
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface CategoryRepository : JpaRepository<Category, String> {
    fun findByName(name: String): Optional<Category>
    fun existsByName(name: String): Boolean
} 