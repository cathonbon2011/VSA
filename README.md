# VSA — Nhận diện Phase Wyckoff từ ảnh chart

CLI Python: đưa vào 1 ảnh chụp biểu đồ giá (chứng khoán, coin, forex...), công cụ sẽ dùng
Claude vision để phân tích theo **phương pháp Wyckoff** kết hợp **VSA (Volume Spread Analysis)**
và cho biết tài sản đang ở phase nào (Tích lũy A-E, Markup, Phân phối A-E, Markdown, Tái tích
lũy, Tái phân phối), kèm các sự kiện Wyckoff (SC, AR, ST, Spring, SOS, LPS, UT, SOW...) và tín
hiệu VSA nhận diện được trên ảnh.

## Cài đặt

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# hoặc cài như 1 lệnh CLI:
pip install -e .
```

Lấy API key tại https://console.anthropic.com/ rồi thiết lập:

```bash
cp .env.example .env
# sửa .env, điền ANTHROPIC_API_KEY=sk-ant-...
export ANTHROPIC_API_KEY=sk-ant-...   # hoặc export trực tiếp, hoặc truyền --api-key
```

## Sử dụng

```bash
python -m wyckoff_vsa.cli path/to/chart.png

# hoặc nếu đã pip install -e .
wyckoff-vsa path/to/chart.png

# thêm bối cảnh để hỗ trợ phân tích tốt hơn
wyckoff-vsa chart.png --context "khung H4, đã giảm mạnh 2 tháng trước đó"

# xuất JSON thô (tiện tích hợp vào app/script khác)
wyckoff-vsa chart.png --json > result.json
```

### Ví dụ output

```
╭─────────────────── Kết quả phân tích Wyckoff/VSA ───────────────────╮
│ Phase nhận diện: Tích lũy - Giai đoạn C (test cuối / Spring)        │
│ Độ tin cậy: 72%                                                     │
│ Mã/ticker: (không xác định)   |   Khung thời gian: Daily            │
│ Có dữ liệu volume: Có                                                │
╰───────────────────────────────────────────────────────────────────╯
                 Các sự kiện Wyckoff nhận diện được
┌────────┬───────────────────┬──────────────────┬───────────────────┐
│ Mã     │ Sự kiện           │ Vị trí           │ Mô tả              │
├────────┼───────────────────┼──────────────────┼───────────────────┤
│ SC     │ Selling Climax    │ Bên trái biểu đồ │ Volume rất lớn...  │
│ Spring │ Spring/Shakeout   │ Gần phải, đáy    │ Phá đáy range...   │
└────────┴───────────────────┴──────────────────┴───────────────────┘
...
```

## Cấu trúc project

```
wyckoff_vsa/
  cli.py        # entry point dòng lệnh (argparse)
  analyzer.py   # chuẩn bị ảnh + gọi Claude API (tool use để ép JSON có cấu trúc)
  schema.py     # định nghĩa các phase Wyckoff + schema tool report_wyckoff_analysis
  prompts.py    # system prompt mô tả đầy đủ phương pháp Wyckoff/VSA
  formatter.py  # hiển thị kết quả đẹp trên terminal bằng rich
```

## Giới hạn cần lưu ý

- Đây là phân tích bằng AI dựa trên **một ảnh tĩnh**, mang tính tham khảo học thuật về phân
  tích kỹ thuật — **không phải lời khuyên đầu tư**.
- Độ chính xác phụ thuộc chất lượng ảnh: nên chụp ảnh rõ nét, có đủ trục giá, và tốt nhất là có
  hiển thị volume (khối lượng) vì đây là yếu tố cốt lõi của VSA.
- Việc phân loại phase Wyckoff vốn mang tính chủ quan ngay cả với chuyên gia con người; hãy coi
  đây là một góc nhìn tham khảo, không phải kết luận tuyệt đối.
