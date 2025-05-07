# 🎩 Trình Chiếu Slide Bằng Flutter

**Phiên bản:** `1.0.0`
**Flutter SDK:** `>=3.10.0 <4.0.0`
**Flutter Version:** `3.24.5`

Ứng dụng trình chiếu slide động, hỗ trợ nhiều loại nội dung như văn bản, hình ảnh, video và âm thanh. Slide được định nghĩa qua tệp JSON với bố cục linh hoạt, hiệu ứng đa dạng và khả năng mở rộng mạnh mẽ.

---

## 🚀 Tính Năng Chính

* 🤩 Hiển thị slide từ tệp JSON (hoặc API nếu mở rộng).
* 🎨 Hỗ trợ các thành phần nội dung:

    * Văn bản HTML (tùy biến phông, cỡ, màu, bóng, viền...)
    * Hình ảnh (network) với hiệu ứng filter, clip shape, lật hình...
    * Video từ YouTube hoặc URL trực tiếp.
    * Âm thanh từ URL.
* 📀 Bố cục tùy chỉnh với `left`, `top`, `width`, `height` (dạng phần trăm).
* 📱 Giao diện responsive tự động co giãn theo kích thước màn hình.
* 🔀 Điều hướng slide thủ công hoặc tự động.
* 🧱 Kiến trúc mô-đun dễ mở rộng & đóng gói.

---

## 🏎️ Các Thư Viện Sử Dụng

| Tên Package               | Chức năng                                     |
| ------------------------- | --------------------------------------------- |
| `flutter_html`            | Hiển thị nội dung văn bản HTML                |
| `youtube_player_flutter`  | Phát video YouTube                            |
| `better_player`           | Phát video từ URL (network/local)             |
| `just_audio`              | Phát âm thanh (network/local)                 |
| `audioplayers` (tuỳ chọn) | Thay thế cho just\_audio nếu cần đơn giản hơn |
| `google_fonts`            | Sử dụng font tùy chỉnh từ Google Fonts        |
| `flutter_svg`             | Hỗ trợ hình ảnh SVG                           |
| `vector_math`             | Xử lý clip hình ảnh polygon/star              |
| `flutter_hooks`           | Quản lý trạng thái linh hoạt (nếu dùng)       |
| `provider`                | Quản lý state cho slide hiện tại (nếu dùng)   |

---

## 📁 Cấu Trúc Slide JSON

```json
{
  "slides": [
    {
      "elements": [
        {
          "type": "text",
          "content": "<h1>Xin chào!</h1><p>Đây là một slide</p>",
          "left": 10,
          "top": 10,
          "width": 80,
          "height": 30,
          "style": {
            "fontSize": 24,
            "fontFamily": "Roboto",
            "color": "#222222",
            "shadow": {
              "color": "#000000",
              "blurRadius": 4,
              "offsetX": 2,
              "offsetY": 2
            },
            "outline": {
              "color": "#FF0000",
              "width": 2
            }
          }
        },
        {
          "type": "image",
          "url": "https://example.com/sample.png",
          "left": 10,
          "top": 50,
          "width": 60,
          "height": 40,
          "shape": "circle",
          "filter": {
            "blur": 1.5,
            "grayscale": 0.2
          }
        }
      ]
    }
  ]
}
```

---

## 🔧 Cài Đặt & Chạy Ứng Dụng

### 1. Clone Dự Án

```bash
git clone https://github.com/iamHaiNQ/app_slide.git
cd flutter_slide_viewer
```

### 2. Cài Đặt Phụ Thuộc

```bash
flutter pub get
```

### 3. Chạy Ứng Dụng

```bash
flutter run
```

> 📁 Dữ liệu slide mẫu nằm tại: `assets/slides.json`

---

## 🧱 Kiến Trúc Code

* `/widgets/slide_widget.dart`: widget chính hiển thị slide.
* `/elements/`: chứa các widget `TextElementWidget`, `ImageElementWidget`, `VideoElementWidget`, `AudioElementWidget`.
* `/utils/layout_parser.dart`: chuyển đổi layout từ phần trăm sang pixel.
* `/utils/html_text_renderer.dart`: parse HTML và render văn bản styled.
* `/media_controllers/`: bộ điều khiển media (YouTube, video, audio).

---

## 🌟 Đóng Gói Thành Package (Tuỳ chọn)

Dự án có thể đóng gói thành thư viện dùng trong các app khác:

```dart
SlideViewer.fromJson(slideData);
```

