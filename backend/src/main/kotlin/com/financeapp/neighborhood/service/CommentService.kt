package com.financeapp.neighborhood.service

import com.financeapp.neighborhood.api.dto.CommentDTO
import com.financeapp.neighborhood.api.dto.CommentPageDTO
import com.financeapp.neighborhood.api.dto.CreateCommentRequest
import com.financeapp.neighborhood.api.dto.UpdateCommentRequest
import com.financeapp.neighborhood.domain.entity.Comment
import com.financeapp.neighborhood.domain.entity.CommentLike
import com.financeapp.neighborhood.domain.entity.CommentLikeId
import com.financeapp.neighborhood.domain.repository.CommentLikeRepository
import com.financeapp.neighborhood.domain.repository.CommentRepository
import com.financeapp.neighborhood.domain.repository.PostRepository
import com.financeapp.neighborhood.domain.repository.UserRepository
import jakarta.persistence.EntityNotFoundException
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
import org.springframework.messaging.simp.SimpMessagingTemplate
class CommentService(
    private val commentRepository: CommentRepository,
    private val postRepository: PostRepository,
    private val userRepository: UserRepository,
    private val commentLikeRepository: CommentLikeRepository,
    private val messagingTemplate: SimpMessagingTemplate
) {

    @Transactional(readOnly = true)
    fun getCommentsByPostId(postId: String, page: Int, size: Int, userId: String?): CommentPageDTO {
        val pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "createdAt"))
        val comments = commentRepository.findByPostId(postId, pageable)
        
        val commentDTOs = comments.content.map { comment -> CommentDTO.fromEntity(comment, userId) }
        
        return CommentPageDTO(
            content = commentDTOs,
            page = comments.number,
            size = comments.size,
            totalElements = comments.totalElements,
            totalPages = comments.totalPages,
            last = comments.isLast
        )
    }
    
    @Transactional
    fun createComment(request: CreateCommentRequest, authorId: String): CommentDTO {
        val author = userRepository.findById(authorId)
            .orElseThrow { EntityNotFoundException("User not found with id: $authorId") }
        
        val post = postRepository.findById(request.postId)
            .orElseThrow { EntityNotFoundException("Post not found with id: ${request.postId}") }
        
        val comment = Comment(
            author = author,
            content = request.content
        )
        
        post.addComment(comment)
        val savedComment = commentRepository.save(comment)
        val commentDTO = CommentDTO.fromEntity(savedComment, authorId)
        // Broadcast new comment event
        val event = com.financeapp.neighborhood.api.dto.NeighborhoodEvent(
            type = "NEW_COMMENT",
            payload = commentDTO
        )
        messagingTemplate.convertAndSend("/topic/neighborhood", event)
        return commentDTO
    }
    
    @Transactional
    fun updateComment(commentId: String, request: UpdateCommentRequest, userId: String): CommentDTO {
        val comment = commentRepository.findById(commentId)
            .orElseThrow { EntityNotFoundException("Comment not found with id: $commentId") }
        
        // Check if user is the author
        if (comment.author.id != userId) {
            throw IllegalAccessException("User is not authorized to update this comment")
        }
        
        // Create a new comment with updated content
        val updatedComment = Comment(
            id = comment.id,
            post = comment.post,
            author = comment.author,
            content = request.content,
            createdAt = comment.createdAt,
            likes = comment.likes
        )
        
        val savedComment = commentRepository.save(updatedComment)
        return CommentDTO.fromEntity(savedComment, userId)
    }
    
    @Transactional
    fun deleteComment(commentId: String, userId: String) {
        val comment = commentRepository.findById(commentId)
            .orElseThrow { EntityNotFoundException("Comment not found with id: $commentId") }
        
        // Check if user is the author
        if (comment.author.id != userId) {
            throw IllegalAccessException("User is not authorized to delete this comment")
        }
        
        commentRepository.delete(comment)
    }
    
    @Transactional
    fun likeComment(commentId: String, userId: String): Map<String, Any> {
        val comment = commentRepository.findById(commentId)
            .orElseThrow { EntityNotFoundException("Comment not found with id: $commentId") }
        
        val user = userRepository.findById(userId)
            .orElseThrow { EntityNotFoundException("User not found with id: $userId") }
        
        val commentLikeId = CommentLikeId(commentId = commentId, userId = userId)
        val likeExists = commentLikeRepository.existsByIdCommentIdAndIdUserId(commentId, userId)
        
        if (likeExists) {
            // Remove like
            val commentLike = commentLikeRepository.findByIdCommentIdAndIdUserId(commentId, userId)
                .orElseThrow { EntityNotFoundException("Like not found") }
            
            comment.removeLike(commentLike)
            commentLikeRepository.delete(commentLike)
            
            return mapOf(
                "likeCount" to comment.getLikeCount(),
                "isLiked" to false
            )
        } else {
            // Add like
            val commentLike = CommentLike(id = commentLikeId, user = user)
            comment.addLike(commentLike)
            commentLikeRepository.save(commentLike)
            
            return mapOf(
                "likeCount" to comment.getLikeCount(),
                "isLiked" to true
            )
        }
    }
} 