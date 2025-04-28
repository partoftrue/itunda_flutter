package com.financeapp.neighborhood.api.dto

import com.financeapp.neighborhood.domain.entity.Comment
import java.time.LocalDateTime

data class CommentDTO(
    val id: String,
    val postId: String,
    val authorId: String,
    val authorName: String,
    val authorProfileImage: String?,
    val content: String,
    val createdAt: LocalDateTime,
    val likeCount: Int,
    val isLiked: Boolean
) {
    companion object {
        fun fromEntity(comment: Comment, userId: String? = null): CommentDTO {
            val author = comment.author
            return CommentDTO(
                id = comment.id,
                postId = comment.post?.id ?: "",
                authorId = author.id,
                authorName = "${author.firstName} ${author.lastName ?: ""}".trim(),
                authorProfileImage = author.profileImageUrl,
                content = comment.content,
                createdAt = comment.createdAt,
                likeCount = comment.getLikeCount(),
                isLiked = userId?.let { comment.isLikedBy(it) } ?: false
            )
        }
    }
}

data class CommentPageDTO(
    val content: List<CommentDTO>,
    val page: Int,
    val size: Int,
    val totalElements: Long,
    val totalPages: Int,
    val last: Boolean
) 