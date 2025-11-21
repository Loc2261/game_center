# Game Center

Giới thiệu
---------
Game Center là một ứng dụng Flutter chứa nhiều trò chơi nhỏ và công cụ hỗ trợ (Tetris, Caro, Cubic/Rubik solver, Puzzle, v.v.). Mục tiêu của dự án là làm mẫu kiến trúc ứng dụng game trên di động/desktop: tách riêng logic game, UI, và dịch vụ mạng; cung cấp widget tái sử dụng, provider cho state và ví dụ tích hợp leaderboard / friends / chat.

Tính năng chính
---------------
- Tetris: gameplay đầy đủ (spawn, rotation, SRS, hold, next queue, scoring, game over, pause).
- Caro (Gomoku): bàn cờ, kiểm tra thắng thua, UI chơi hai người.
- Cubic Solver: nhập trạng thái khối (3x3), hiển thị 3D, tính toán chuỗi nước đi giải.
- Puzzle: màn setup và chơi puzzle, hỗ trợ gọi API.
- Hệ thống hỗ trợ: auth, friends, chat, leaderboard, storage service.
- Widgets dùng chung: HUD, board, controls, placeholder screens, loading/error widgets.

Cấu trúc mã nguồn (tổng quan)
-----------------------------
lib/
- main.dart — entry point  
- config/ — theme, constants  
- games/ — module game (puzzle, tetris, ...)  
- models/ — mô hình dữ liệu (user, game state, tetromino, ...)  
- providers/ — ChangeNotifier / provider cho trạng thái ứng dụng  
- screens/ — các màn chính (home, login, profile, splash, v.v.)  
- services/ — tương tác API (auth, game, chat, leaderboard, storage)  
- widgets/ — widget tái sử dụng (common, game, cubic, ...)



Chi tiết các thuật toán chính
------------------------------

1) Tetris (lib/games/tetris)
- Đại diện tetromino: mỗi khối có các rotation state (mảng ma trận nhỏ).  
- Kiểm tra va chạm: so sánh tetromino cells với lưới (grid) hiện tại, rơi theo gravity mỗi tick.  
- Super Rotation System (SRS): danh sách offset thử khi quay để xử lý wall kicks; sử dụng dữ liệu trong `srs_data.dart`.  
- Lock & gravity: controller quản lý tick, soft drop, hard drop, lock delay.  
- Line clear: quét từng hàng, xóa hàng đầy và dịch các hàng trên xuống.  
- Scoring & level: điểm cộng theo số hàng clear (single, double, triple, tetris) và theo drop; level tăng theo số hàng đã clear để tăng tốc gravity.  
- Kiến nghị tối ưu: nếu cần performance, chuyển từ grid 2D sang bitboard/bitmask để tính va chạm và clear hàng nhanh hơn.

2) Cubic / Rubik-like Solver (lib/widgets/cubic, providers)
- Lưu trạng thái: 6 mặt × 9 ô (3x3) hoặc cấu trúc tương đương.  
- Bộ giải: có thể triển khai:
  - IDA* với heuristic đơn giản (số ô sai, Manhattan-like trên sticker) cho demo.
  - Hoặc Kociemba 2-phase (nếu cần hiệu năng/độ ngắn lời giải).  
- Triển khai hiện tại: provider chịu trách nhiệm chạy thuật toán giải và trả chuỗi nước đi; giao diện hiển thị bằng `solution_display.dart` và `cube_3d_viewer.dart`.  
- Gợi ý cải thiện: tích hợp thư viện Kociemba hoặc native extension để giảm thời gian giải.

3) Puzzle (lib/games/puzzle)
- Loại puzzle thường là sliding/tile hoặc jigsaw (tuỳ implement).  
- Nếu là sliding puzzle, thuật toán giải tự động: A* với heuristic Manhattan distance để tìm đường hiệu quả.  
- `puzzle_api_service.dart` dùng để lấy tài nguyên (ảnh, mức độ) và gửi highscore.

4) Caro / Gomoku (lib/screens/caro_game_screen.dart)
- Kiểm tra thắng: quét hàng, cột và hai đường chéo để tìm chuỗi liên tiếp (ví dụ 5 in-a-row).  
- Lưu lịch sử nước đi để undo/redo.  
- AI: không tích hợp sẵn; có thể thêm Minimax với alpha-beta pruning và heuristic dựa trên open-three/open-four patterns.

Dịch vụ & kiến trúc mạng
-------------------------
- services/*: wrapper HTTP/REST cho auth, game, chat, friend, leaderboard.  
- providers/*: quản lý state với ChangeNotifier; UI tiêu thụ provider để cập nhật realtime.  
- Debugging: bật logging trong api_service để xem request/response.



Mẹo refactor & bảo trì
----------------------
- Dùng package imports (ví dụ `package:game_center/widgets/...`) để nhất quán.  
- Tạo barrel exports (ví dụ `lib/widgets/game/widgets.dart`) nếu muốn import ngắn gọn.  
- Tách styles/constants vào `lib/config` để dễ theme hoá.  
- Tách logic game khỏi UI (đã làm theo pattern controller/provider) để dễ test.

Đóng góp
--------
- Fork → feature branch → PR.  
- Viết test cho logic mới.  
- Tránh commit file build/generated; thêm .gitignore phù hợp.

Giấy phép
---------
- Hiện repo chưa kèm LICENSE; thêm license (MIT/Apache) nếu định công khai.

Liên hệ / Hỗ trợ
----------------
email: locdinh226@gmail.com  
SDT: 0911635059
