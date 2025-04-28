package com.financeapp.neighborhood.domain.repository

import com.financeapp.neighborhood.domain.entity.CommentLike
import com.financeapp.neighborhood.domain.entity.CommentLikeId
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface CommentLikeRepository : JpaRepository<CommentLike, CommentLikeId> {
    fun findByIdCommentIdAndIdUserId(commentId: String, userId: String): Optional<CommentLike>
    fun existsByIdCommentIdAndIdUserId(commentId: String, userId: String): Boolean
    fun countByIdCommentId(commentId: String): Int
} 