package com.financeapp.neighborhood.domain.repository

import com.financeapp.neighborhood.domain.entity.Comment
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CommentRepository : JpaRepository<Comment, String> {
    fun findByPostId(postId: String, pageable: Pageable): Page<Comment>
} 