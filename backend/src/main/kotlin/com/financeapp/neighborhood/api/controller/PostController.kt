package com.financeapp.neighborhood.api.controller

import com.financeapp.neighborhood.api.dto.CreatePostRequest
import com.financeapp.neighborhood.api.dto.PostDTO
import com.financeapp.neighborhood.api.dto.PostPageDTO
import com.financeapp.neighborhood.api.dto.UpdatePostRequest
import com.financeapp.neighborhood.service.PostService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/posts")
class PostController(private val postService: PostService) {

    @GetMapping
    fun getPosts(
        @RequestParam location: String,
        @RequestParam(defaultValue = "전체") category: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @AuthenticationPrincipal userDetails: UserDetails?
    ): ResponseEntity<PostPageDTO> {
        val userId = userDetails?.username
        return ResponseEntity.ok(postService.getPosts(location, category, page, size, userId))
    }
    
    @GetMapping("/popular")
    fun getPopularPosts(
        @RequestParam location: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "10") size: Int,
        @AuthenticationPrincipal userDetails: UserDetails?
    ): ResponseEntity<PostPageDTO> {
        val userId = userDetails?.username
        return ResponseEntity.ok(postService.getPopularPosts(location, page, size, userId))
    }
    
    @GetMapping("/{postId}")
    fun getPostById(
        @PathVariable postId: String,
        @RequestParam location: String,
        @AuthenticationPrincipal userDetails: UserDetails?
    ): ResponseEntity<PostDTO> {
        val userId = userDetails?.username
        return ResponseEntity.ok(postService.getPostById(postId, userId, location))
    }
    
    @PostMapping
    fun createPost(
        @Valid @RequestBody request: CreatePostRequest,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<PostDTO> {
        val authorId = userDetails.username
        val createdPost = postService.createPost(request, authorId)
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPost)
    }
    
    @PutMapping("/{postId}")
    fun updatePost(
        @PathVariable postId: String,
        @Valid @RequestBody request: UpdatePostRequest,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<PostDTO> {
        val userId = userDetails.username
        val updatedPost = postService.updatePost(postId, request, userId)
        return ResponseEntity.ok(updatedPost)
    }
    
    @DeleteMapping("/{postId}")
    fun deletePost(
        @PathVariable postId: String,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<Void> {
        val userId = userDetails.username
        postService.deletePost(postId, userId)
        return ResponseEntity.noContent().build()
    }
    
    @PostMapping("/{postId}/like")
    fun likePost(
        @PathVariable postId: String,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<Map<String, Any>> {
        val userId = userDetails.username
        val response = postService.likePost(postId, userId)
        return ResponseEntity.ok(response)
    }
} 