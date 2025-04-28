package com.financeapp.neighborhood.domain.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "posts")
data class Post(
    @Id
    val id: String = UUID.randomUUID().toString(),
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    val author: User,
    
    @Column(nullable = false)
    val title: String,
    
    @Column(nullable = false)
    val content: String,
    
    @Column(nullable = false)
    val category: String,
    
    @Column(nullable = false)
    val location: String,
    
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
    
    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),
    
    @OneToMany(mappedBy = "post", cascade = [CascadeType.ALL], orphanRemoval = true)
    val comments: MutableList<Comment> = mutableListOf(),
    
    @OneToMany(mappedBy = "post", cascade = [CascadeType.ALL], orphanRemoval = true)
    val likes: MutableList<PostLike> = mutableListOf(),
    
    @OneToMany(mappedBy = "post", cascade = [CascadeType.ALL], orphanRemoval = true)
    val images: MutableList<PostImage> = mutableListOf()
) {
    fun addComment(comment: Comment) {
        comments.add(comment)
        comment.post = this
    }
    
    fun removeComment(comment: Comment) {
        comments.remove(comment)
        comment.post = null
    }
    
    fun addLike(like: PostLike) {
        likes.add(like)
        like.post = this
    }
    
    fun removeLike(like: PostLike) {
        likes.remove(like)
        like.post = null
    }
    
    fun addImage(image: PostImage) {
        images.add(image)
        image.post = this
    }
    
    fun removeImage(image: PostImage) {
        images.remove(image)
        image.post = null
    }
    
    fun isLikedBy(userId: String): Boolean {
        return likes.any { it.user.id == userId }
    }
    
    fun getLikeCount(): Int {
        return likes.size
    }
    
    fun getCommentCount(): Int {
        return comments.size
    }
} 