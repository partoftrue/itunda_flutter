package com.financeapp.neighborhood.api.controller

import com.financeapp.neighborhood.api.dto.CommentDTO
import com.financeapp.neighborhood.api.dto.CommentPageDTO
import com.financeapp.neighborhood.api.dto.CreateCommentRequest
import com.financeapp.neighborhood.api.dto.UpdateCommentRequest
import com.financeapp.neighborhood.service.CommentService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/comments")
class CommentController(private val commentService: CommentService) {

    @GetMapping("/post/{postId}")
    fun getCommentsByPostId(
        @PathVariable postId: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @AuthenticationPrincipal userDetails: UserDetails?
    ): ResponseEntity<CommentPageDTO> {
        val userId = userDetails?.username
        return ResponseEntity.ok(commentService.getCommentsByPostId(postId, page, size, userId))
    }
    
    @PostMapping
    fun createComment(
        @Valid @RequestBody request: CreateCommentRequest,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<CommentDTO> {
        val authorId = userDetails.username
        val createdComment = commentService.createComment(request, authorId)
        return ResponseEntity.status(HttpStatus.CREATED).body(createdComment)
    }
    
    @PutMapping("/{commentId}")
    fun updateComment(
        @PathVariable commentId: String,
        @Valid @RequestBody request: UpdateCommentRequest,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<CommentDTO> {
        val userId = userDetails.username
        val updatedComment = commentService.updateComment(commentId, request, userId)
        return ResponseEntity.ok(updatedComment)
    }
    
    @DeleteMapping("/{commentId}")
    fun deleteComment(
        @PathVariable commentId: String,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<Void> {
        val userId = userDetails.username
        commentService.deleteComment(commentId, userId)
        return ResponseEntity.noContent().build()
    }
    
    @PostMapping("/{commentId}/like")
    fun likeComment(
        @PathVariable commentId: String,
        @AuthenticationPrincipal userDetails: UserDetails
    ): ResponseEntity<Map<String, Any>> {
        val userId = userDetails.username
        val response = commentService.likeComment(commentId, userId)
        return ResponseEntity.ok(response)
    }
} 