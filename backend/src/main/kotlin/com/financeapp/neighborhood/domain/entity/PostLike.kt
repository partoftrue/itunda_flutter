package com.financeapp.neighborhood.domain.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "post_likes")
data class PostLike(
    @EmbeddedId
    val id: PostLikeId = PostLikeId(),
    
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("postId")
    @JoinColumn(name = "post_id")
    var post: Post? = null,
    
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    val user: User,
    
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now()
)

@Embeddable
data class PostLikeId(
    @Column(name = "post_id")
    var postId: String = "",
    
    @Column(name = "user_id")
    var userId: String = ""
) : java.io.Serializable 