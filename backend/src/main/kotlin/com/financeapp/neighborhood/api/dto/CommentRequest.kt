package com.financeapp.neighborhood.api.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

data class CreateCommentRequest(
    @field:NotNull(message = "게시물 ID는 필수입니다")
    val postId: String,
    
    @field:NotBlank(message = "댓글 내용은 필수입니다")
    val content: String
)

data class UpdateCommentRequest(
    @field:NotBlank(message = "댓글 내용은 필수입니다")
    val content: String
) 