package com.financeapp.neighborhood.api.dto

import jakarta.validation.constraints.NotBlank

data class CreatePostRequest(
    @field:NotBlank(message = "제목은 필수입니다")
    val title: String,
    
    @field:NotBlank(message = "내용은 필수입니다")
    val content: String,
    
    @field:NotBlank(message = "카테고리는 필수입니다")
    val category: String,
    
    @field:NotBlank(message = "위치는 필수입니다")
    val location: String,
    
    val imageUrls: List<String>? = null
)

data class UpdatePostRequest(
    val title: String? = null,
    val content: String? = null,
    val category: String? = null,
    val imageUrls: List<String>? = null
) 