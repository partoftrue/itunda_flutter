package com.financeapp.neighborhood.domain.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "comment_likes")
data class CommentLike(
    @EmbeddedId
    val id: CommentLikeId = CommentLikeId(),
    
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("commentId")
    @JoinColumn(name = "comment_id")
    var comment: Comment? = null,
    
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    val user: User,
    
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now()
)

@Embeddable
data class CommentLikeId(
    @Column(name = "comment_id")
    var commentId: String = "",
    
    @Column(name = "user_id")
    var userId: String = ""
) : java.io.Serializable 