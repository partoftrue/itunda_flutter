package com.financeapp.neighborhood.service

import com.financeapp.neighborhood.api.dto.*
import com.financeapp.neighborhood.domain.entity.Post
import com.financeapp.neighborhood.domain.entity.PostImage
import com.financeapp.neighborhood.domain.entity.PostLike
import com.financeapp.neighborhood.domain.entity.PostLikeId
import com.financeapp.neighborhood.domain.repository.PostLikeRepository
import com.financeapp.neighborhood.domain.repository.PostRepository
import com.financeapp.neighborhood.domain.repository.UserRepository
import jakarta.persistence.EntityNotFoundException
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
import org.springframework.messaging.simp.SimpMessagingTemplate
class PostService(
    private val postRepository: PostRepository,
    private val userRepository: UserRepository,
    private val postLikeRepository: PostLikeRepository,
    private val messagingTemplate: SimpMessagingTemplate
) {

    @Transactional(readOnly = true)
    fun getPosts(location: String, category: String, page: Int, size: Int, userId: String?): PostPageDTO {
        val pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"))
        
        val posts: Page<Post> = if (category == "전체") {
            postRepository.findByLocation(location, pageable)
        } else {
            postRepository.findByCategoryAndLocation(category, location, pageable)
        }
        
        return toPostPageDTO(posts, userId)
    }
    
    @Transactional(readOnly = true)
    fun getPopularPosts(location: String, page: Int, size: Int, userId: String?): PostPageDTO {
        val pageable = PageRequest.of(page, size)
        val posts = postRepository.findPopularPostsByLocation(location, pageable)
        
        return toPostPageDTO(posts, userId)
    }
    
    @Transactional(readOnly = true)
    fun getPostById(postId: String, userId: String?, location: String): PostDTO {
        val post = postRepository.findById(postId)
            .orElseThrow { EntityNotFoundException("Post not found with id: $postId") }
        
        return PostDTO.fromEntity(post, userId)
    }
    
    @Transactional
    fun createPost(request: CreatePostRequest, authorId: String): PostDTO {
        val author = userRepository.findById(authorId)
            .orElseThrow { EntityNotFoundException("User not found with id: $authorId") }
        
        val post = Post(
            author = author,
            title = request.title,
            content = request.content,
            category = request.category,
            location = request.location
        )
        
        // Add images if provided
        request.imageUrls?.forEach { imageUrl ->
            post.addImage(PostImage(imageUrl = imageUrl))
        }
        
        val savedPost = postRepository.save(post)
        val postDTO = PostDTO.fromEntity(savedPost, authorId)
        // Broadcast new post event
        val event = com.financeapp.neighborhood.api.dto.NeighborhoodEvent(
            type = "NEW_POST",
            payload = postDTO
        )
        messagingTemplate.convertAndSend("/topic/neighborhood", event)
        return postDTO
    }
    
    @Transactional
    fun updatePost(postId: String, request: UpdatePostRequest, userId: String): PostDTO {
        val post = postRepository.findById(postId)
            .orElseThrow { EntityNotFoundException("Post not found with id: $postId") }
        
        // Check if user is the author
        if (post.author.id != userId) {
            throw IllegalAccessException("User is not authorized to update this post")
        }
        
        // Create a new post object with updated fields
        val updatedPost = Post(
            id = post.id,
            author = post.author,
            title = request.title ?: post.title,
            content = request.content ?: post.content,
            category = request.category ?: post.category,
            location = post.location,
            createdAt = post.createdAt,
            updatedAt = LocalDateTime.now(),
            comments = post.comments,
            likes = post.likes,
            images = post.images
        )
        
        // Update images if provided
        if (request.imageUrls != null) {
            // Clear existing images
            post.images.clear()
            
            // Add new images
            request.imageUrls.forEach { imageUrl ->
                updatedPost.addImage(PostImage(imageUrl = imageUrl))
            }
        }
        
        val savedPost = postRepository.save(updatedPost)
        return PostDTO.fromEntity(savedPost, userId)
    }
    
    @Transactional
    fun deletePost(postId: String, userId: String) {
        val post = postRepository.findById(postId)
            .orElseThrow { EntityNotFoundException("Post not found with id: $postId") }
        
        // Check if user is the author
        if (post.author.id != userId) {
            throw IllegalAccessException("User is not authorized to delete this post")
        }
        
        postRepository.delete(post)
    }
    
    @Transactional
    fun likePost(postId: String, userId: String): Map<String, Any> {
        val post = postRepository.findById(postId)
            .orElseThrow { EntityNotFoundException("Post not found with id: $postId") }
        
        val user = userRepository.findById(userId)
            .orElseThrow { EntityNotFoundException("User not found with id: $userId") }
        
        val postLikeId = PostLikeId(postId = postId, userId = userId)
        val likeExists = postLikeRepository.existsByIdPostIdAndIdUserId(postId, userId)
        
        if (likeExists) {
            // Remove like
            val postLike = postLikeRepository.findByIdPostIdAndIdUserId(postId, userId)
                .orElseThrow { EntityNotFoundException("Like not found") }
            
            post.removeLike(postLike)
            postLikeRepository.delete(postLike)
            
            return mapOf(
                "likeCount" to post.getLikeCount(),
                "isLiked" to false
            )
        } else {
            // Add like
            val postLike = PostLike(id = postLikeId, user = user)
            post.addLike(postLike)
            postLikeRepository.save(postLike)
            
            return mapOf(
                "likeCount" to post.getLikeCount(),
                "isLiked" to true
            )
        }
    }
    
    private fun toPostPageDTO(posts: Page<Post>, userId: String?): PostPageDTO {
        val postDTOs = posts.content.map { post -> PostDTO.fromEntity(post, userId) }
        
        return PostPageDTO(
            content = postDTOs,
            page = posts.number,
            size = posts.size,
            totalElements = posts.totalElements,
            totalPages = posts.totalPages,
            last = posts.isLast
        )
    }
} 