package com.example.ProductDetails.service;

import java.util.Base64;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.ProductDetails.dto.ProductDTO;
import com.example.ProductDetails.entity.Product;
import com.example.ProductDetails.repository.ProductRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository repo;

    @Override
    public Product addProduct(ProductDTO dto, MultipartFile photo) throws Exception {
        String base64 = Base64.getEncoder().encodeToString(photo.getBytes());

        Product product = Product.builder()
                .name(dto.getName())
                .price(dto.getPrice())
                .description(dto.getDescription())
                .photoBase64(base64)
                .build();

        return repo.save(product);
    }

    @Override
    public Product updateProduct(Long id, ProductDTO dto, MultipartFile photo) throws Exception {
        Product existing = repo.findById(id).orElseThrow(() -> new RuntimeException("Product not found"));

        existing.setName(dto.getName());
        existing.setPrice(dto.getPrice());
        existing.setDescription(dto.getDescription());

        if (photo != null && !photo.isEmpty()) {
            existing.setPhotoBase64(Base64.getEncoder().encodeToString(photo.getBytes()));
        }

        return repo.save(existing);
    }

    @Override
    public Product getProduct(Long id) {
        return repo.findById(id).orElseThrow(() -> new RuntimeException("Product not found"));
    }

    @Override
    public List<Product> getAllProducts() {
        return repo.findAll();
    }

    @Override
    public void deleteProduct(Long id) {
        repo.deleteById(id);
    }
}

