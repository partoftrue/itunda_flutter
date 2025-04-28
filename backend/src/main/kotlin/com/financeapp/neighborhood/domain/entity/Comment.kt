package com.financeapp.neighborhood.domain.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "comments")
data class Comment(
    @Id
    val id: String = UUID.randomUUID().toString(),
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id")
    var post: Post? = null,
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    val author: User,
    
    @Column(nullable = false)
    val content: String,
    
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    
    @OneToMany(mappedBy = "comment", cascade = [CascadeType.ALL], orphanRemoval = true)
    val likes: MutableList<CommentLike> = mutableListOf()
) {
    fun addLike(like: CommentLike) {
        likes.add(like)
        like.comment = this
    }
    
    fun removeLike(like: CommentLike) {
        likes.remove(like)
        like.comment = null
    }
    
    fun isLikedBy(userId: String): Boolean {
        return likes.any { it.user.id == userId }
    }
    
    fun getLikeCount(): Int {
        return likes.size
    }
} 