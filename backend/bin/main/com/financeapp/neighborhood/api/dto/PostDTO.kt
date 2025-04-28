package com.financeapp.neighborhood.api.dto

import com.financeapp.neighborhood.domain.entity.Post
import java.time.LocalDateTime

data class PostDTO(
    val id: String,
    val authorId: String,
    val authorName: String,
    val authorProfileImage: String?,
    val title: String,
    val content: String,
    val category: String,
    val location: String,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
    val likeCount: Int,
    val commentCount: Int,
    val isLiked: Boolean,
    val imageUrls: List<String>
) {
    companion object {
        fun fromEntity(post: Post, userId: String? = null): PostDTO {
            val author = post.author
            return PostDTO(
                id = post.id,
                authorId = author.id,
                authorName = "${author.firstName} ${author.lastName ?: ""}".trim(),
                authorProfileImage = author.profileImageUrl,
                title = post.title,
                content = post.content,
                category = post.category,
                location = post.location,
                createdAt = post.createdAt,
                updatedAt = post.updatedAt,
                likeCount = post.getLikeCount(),
                commentCount = post.getCommentCount(),
                isLiked = userId?.let { post.isLikedBy(it) } ?: false,
                imageUrls = post.images.map { it.imageUrl }
            )
        }
    }
}

data class PostPageDTO(
    val content: List<PostDTO>,
    val page: Int,
    val size: Int,
    val totalElements: Long,
    val totalPages: Int,
    val last: Boolean
) 