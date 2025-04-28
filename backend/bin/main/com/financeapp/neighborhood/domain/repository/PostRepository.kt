package com.financeapp.neighborhood.domain.repository

import com.financeapp.neighborhood.domain.entity.Post
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface PostRepository : JpaRepository<Post, String> {
    fun findByLocation(location: String, pageable: Pageable): Page<Post>
    
    fun findByCategoryAndLocation(category: String, location: String, pageable: Pageable): Page<Post>
    
    @Query("SELECT p FROM Post p JOIN p.likes l GROUP BY p HAVING COUNT(l) > 0 AND p.location = :location ORDER BY COUNT(l) DESC")
    fun findPopularPostsByLocation(location: String, pageable: Pageable): Page<Post>
} 