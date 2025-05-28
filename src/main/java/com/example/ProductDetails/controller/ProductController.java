    package com.example.ProductDetails.controller;

    import java.util.List;

    import org.springframework.http.MediaType;
    import org.springframework.http.ResponseEntity;
    import org.springframework.web.bind.annotation.CrossOrigin;
    import org.springframework.web.bind.annotation.DeleteMapping;
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.PathVariable;
    import org.springframework.web.bind.annotation.PostMapping;
    import org.springframework.web.bind.annotation.PutMapping;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RequestPart;
    import org.springframework.web.bind.annotation.RestController;
    import org.springframework.web.multipart.MultipartFile;

    import com.example.ProductDetails.dto.ProductDTO;
    import com.example.ProductDetails.entity.Product;
    import com.example.ProductDetails.service.ProductService;
    import com.fasterxml.jackson.databind.ObjectMapper;

    import lombok.RequiredArgsConstructor;

    @RestController
    @RequestMapping("/api/products")
    @RequiredArgsConstructor
    @CrossOrigin(origins = "*")
    public class ProductController {

        private final ProductService productService;

        @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Product> addProduct(
            @RequestPart("product") String productJson,
            @RequestPart("photo") MultipartFile photo) throws Exception {

        // Convert JSON string to ProductDTO
        ObjectMapper mapper = new ObjectMapper();
        ProductDTO dto = mapper.readValue(productJson, ProductDTO.class);

        return ResponseEntity.ok(productService.addProduct(dto, photo));
    }


        @PutMapping("/{id}")
        public ResponseEntity<Product> updateProduct(@PathVariable Long id,
                                                    @RequestPart("product") String dto1,
                                                    @RequestPart(value = "photo", required = false) MultipartFile photo) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        ProductDTO dto = mapper.readValue(dto1, ProductDTO.class);
            return ResponseEntity.ok(productService.updateProduct(id, dto, photo));
        }

        @GetMapping("/{id}")
        public ResponseEntity<Product> getProduct(@PathVariable Long id) {
            return ResponseEntity.ok(productService.getProduct(id));
        }

        @GetMapping
        public ResponseEntity<List<Product>> getAllProducts() {
            return ResponseEntity.ok(productService.getAllProducts());
        }

        @DeleteMapping("/{id}")
        public ResponseEntity<String> deleteProduct(@PathVariable Long id) {
            productService.deleteProduct(id);
            return ResponseEntity.ok("Product deleted successfully");
        }
    }
