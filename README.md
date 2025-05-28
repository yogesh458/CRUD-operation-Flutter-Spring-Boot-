# 🛍️ Product Management Application

A full-stack product management application built with **Spring Boot**, **MySQL**, and **Flutter**. This application allows users to **Add**, **Update**, **Delete**, and **View** products with image uploads. It supports both **Android** and **Web** platforms.

---

## 🚀 Features

- Add new products with photo, name, price, and description.
- View all stored products on the main page.
- Update existing product details with or without changing the image.
- Delete a product by ID.
- Cross-platform support for Android and Web.
- Image upload handled with platform-aware logic.

---

## 🧰 Technologies Used

### Backend
- Java 17
- Spring Boot
- Spring Web
- Lombok
- MySQL
- Jackson (for JSON parsing)
- Multipart File Handling

### Frontend (Flutter)
- Flutter SDK
- `http` package
- `image_picker` (for Android/iOS)
- `file_picker` (for Web)
- `mime` & `http_parser` (for handling file types)

---

## ⚙️ Backend API Endpoints

| Method | Endpoint              | Description                    |
|--------|-----------------------|--------------------------------|
| POST   | `/api/products`       | Add a product with image       |
| PUT    | `/api/products/{id}`  | Update product details         |
| GET    | `/api/products`       | Get all products               |
| GET    | `/api/products/{id}`  | Get product by ID              |
| DELETE | `/api/products/{id}`  | Delete product by ID           |

### Multipart Upload
- `@RequestPart("product")`: JSON string of product fields
- `@RequestPart("photo")`: Multipart image file

---

## 🧑‍💻 Flutter Frontend

### Key Features
- Uses `image_picker` for Android/iOS to pick images from the gallery.
- Uses `file_picker` for Web to select images from the file system.
- Automatically detects platform using `kIsWeb` and processes accordingly.
- Submits multipart requests using `http.MultipartRequest`.

### Add Product Screen

- Fields: Product Name, Price, Description, Photo
- Validates all fields before submission.
- Displays uploaded image preview before submitting.
- On successful upload, navigates back to refresh product list.

---

## 🛠️ How to Run

### Backend (Spring Boot)
1. Make sure MySQL is running and create a database:
   ```sql
   CREATE DATABASE productdb;
   
2.Update application.properties with your DB credentials:

spring.datasource.url=jdbc:mysql://localhost:3306/productdb
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update

3.Run the Spring Boot application:
./mvnw spring-boot:run


1.Install dependencies:

flutter pub get

2.Run on desired platform:
For Web:
flutter run -d chrome
For Android:
flutter run
