# Flutter Firestore E-commerce App

Họ và tên: Tran Dat Chien
Mã Sinh Viên: 2251172255
Lớp/Học phần: Lập trình Mobile - Đề số 02

## 📋 Giới thiệu
Ứng dụng quản lý cửa hàng online xây dựng bằng Flutter và Firebase Firestore. Hỗ trợ các chức năng:
- Đăng ký/Đăng nhập (Giả lập qua Firestore).
- Xem danh sách sản phẩm, tìm kiếm, lọc theo danh mục và giá.
- Thêm vào giỏ hàng, quản lý số lượng.
- Đặt hàng (Transaction đảm bảo tính nhất quán tồn kho).
- Xem lịch sử đơn hàng và hủy đơn (nếu chưa xử lý).

## 🛠 Yêu cầu hệ thống
- Flutter SDK: >= 3.0.0
- Dart SDK: >= 2.17.0
- Kết nối Internet (để tải thư viện và kết nối Firebase).

## 🚀 Hướng dẫn Cài đặt & Chạy dự án

### Bước 1: Cài đặt thư viện
Mở terminal tại thư mục gốc của dự án và chạy:
```bash
flutter pub get
```
Bước 2: Cấu hình Firebase
Dự án yêu cầu kết nối với Firebase Project của bạn.

Đảm bảo file lib/firebase_options.dart đã tồn tại (được sinh ra từ flutterfire configure).

Cấu hình Firestore Database Rules ở chế độ Test Mode để tránh lỗi quyền truy cập:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
Bước 3: Chạy ứng dụng
```Bash
flutter run
```
⚡ Hướng dẫn Tạo Dữ liệu Mẫu (Data Seeding)
QUAN TRỌNG: Để chấm bài nhanh, ứng dụng có tích hợp Tool tạo dữ liệu tự động.

Tại màn hình Đăng nhập (Login Screen).

Bấm vào nút màu đỏ "SEED DATA (Chỉ bấm 1 lần)" ở dưới cùng.

Chờ thông báo thành công. Hệ thống sẽ tự động tạo:

5 Khách hàng mẫu.

15 Sản phẩm thuộc 5 danh mục khác nhau.

8 Đơn hàng với các trạng thái khác nhau.

Tài khoản Test (Sau khi Seed Data):
Bạn có thể đăng nhập bằng một trong các email sau (Mật khẩu nhập bất kỳ hoặc để trống):

Email: customer1@example.com

Email: customer2@example.com ...

Email: customer5@example.com

📱 Các tính năng chính
1. Quản lý Khách hàng (Customers)
Đăng ký tài khoản mới (Check trùng email).

Đăng nhập (Lưu session bằng SharedPreferences).

2. Sản phẩm (Products)
Hiển thị danh sách Realtime.

Tìm kiếm: Theo tên, mô tả, thương hiệu.

Bộ lọc:

Lọc theo Danh mục (Dropdown).

Lọc theo Khoảng giá (Min - Max).

Chi tiết: Hiển thị tồn kho, trạng thái "Hết hàng".

3. Giỏ hàng & Đặt hàng (Cart & Order)
Thêm/Sửa/Xóa sản phẩm trong giỏ.

Đặt hàng:

Sử dụng Firestore Transaction để đảm bảo không bị lỗi tồn kho khi nhiều người mua cùng lúc.

Tự động trừ kho (stock) khi đặt.

Validate số lượng tồn kho trước khi tạo đơn.

4. Lịch sử Đơn hàng
Xem danh sách đơn hàng theo trạng thái (Pending, Delivered, Cancelled...).

Hủy đơn hàng: Chỉ cho phép hủy khi trạng thái là pending. Khi hủy, hệ thống tự động hoàn lại số lượng tồn kho cho sản phẩm.

📂 Cấu trúc thư mục
Dự án tuân thủ kiến trúc MVVM & Repository Pattern:

lib/
├── models/          # Data Models (Customer, Product, Order)
├── repositories/    # Logic tương tác Firestore (CRUD, Transaction)
├── providers/       # State Management (Auth, Cart)
├── services/        # Firestore Singleton & Seeding Service
├── screens/         # UI Screens (Auth, Home, Cart, Orders)
├── utils/           # Helper functions
└── main.dart        # Entry point