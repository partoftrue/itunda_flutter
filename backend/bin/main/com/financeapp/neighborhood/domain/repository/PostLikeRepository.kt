package com.financeapp.neighborhood.domain.repository

import com.financeapp.neighborhood.domain.entity.PostLike
import com.financeapp.neighborhood.domain.entity.PostLikeId
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface PostLikeRepository : JpaRepository<PostLike, PostLikeId> {
    fun findByIdPostIdAndIdUserId(postId: String, userId: String): Optional<PostLike>
    fun existsByIdPostIdAndIdUserId(postId: String, userId: String): Boolean
    fun countByIdPostId(postId: String): Int
} 