package com.example.ProductDetails.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.example.ProductDetails.dto.ProductDTO;
import com.example.ProductDetails.entity.Product;

public interface ProductService {
    Product addProduct(ProductDTO dto, MultipartFile photo) throws Exception;
    Product updateProduct(Long id, ProductDTO dto, MultipartFile photo) throws Exception;
    Product getProduct(Long id);
    List<Product> getAllProducts();
    void deleteProduct(Long id);
}

