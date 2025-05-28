package com.example.ProductDetails.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.ProductDetails.entity.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {
}
