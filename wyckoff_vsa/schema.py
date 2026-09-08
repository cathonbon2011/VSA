"""Cấu trúc dữ liệu kết quả phân tích Wyckoff/VSA và schema tool-use cho Claude API."""

PHASE_LABELS_VI = {
    "ACCUMULATION_A": "Tích lũy - Giai đoạn A (chặn đà giảm)",
    "ACCUMULATION_B": "Tích lũy - Giai đoạn B (xây nền, dò cung/cầu)",
    "ACCUMULATION_C": "Tích lũy - Giai đoạn C (test cuối / Spring)",
    "ACCUMULATION_D": "Tích lũy - Giai đoạn D (SOS, xu hướng trong nền rõ dần)",
    "ACCUMULATION_E": "Tích lũy - Giai đoạn E (chuẩn bị thoát nền, sắp Markup)",
    "REACCUMULATION": "Tái tích lũy (nghỉ trong xu hướng tăng)",
    "MARKUP": "Markup - Xu hướng tăng",
    "DISTRIBUTION_A": "Phân phối - Giai đoạn A (chặn đà tăng)",
    "DISTRIBUTION_B": "Phân phối - Giai đoạn B (xây đỉnh, dò cung/cầu)",
    "DISTRIBUTION_C": "Phân phối - Giai đoạn C (test cuối / Upthrust)",
    "DISTRIBUTION_D": "Phân phối - Giai đoạn D (SOW, xu hướng giảm trong đỉnh rõ dần)",
    "DISTRIBUTION_E": "Phân phối - Giai đoạn E (chuẩn bị thoát đỉnh, sắp Markdown)",
    "REDISTRIBUTION": "Tái phân phối (nghỉ trong xu hướng giảm)",
    "MARKDOWN": "Markdown - Xu hướng giảm",
    "UNDETERMINED": "Chưa đủ dữ liệu để xác định rõ phase",
}

PHASE_ENUM = list(PHASE_LABELS_VI.keys())

WYCKOFF_ANALYSIS_TOOL = {
    "name": "report_wyckoff_analysis",
    "description": (
        "Báo cáo kết quả phân tích một ảnh chụp biểu đồ giá chứng khoán theo phương pháp "
        "Wyckoff (Wyckoff Method) kết hợp phân tích VSA (Volume Spread Analysis)."
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "symbol_guess": {
                "type": "string",
                "description": (
                    "Mã cổ phiếu / ticker nếu đọc được trên ảnh (ví dụ VNM, AAPL). "
                    "Để chuỗi rỗng nếu không thấy."
                ),
            },
            "timeframe_guess": {
                "type": "string",
                "description": (
                    "Khung thời gian của biểu đồ nếu suy đoán được (Daily, H4, Weekly, ...). "
                    "Để chuỗi rỗng nếu không rõ."
                ),
            },
            "has_volume_data": {
                "type": "boolean",
                "description": "Ảnh có hiển thị dữ liệu khối lượng giao dịch (volume) hay không.",
            },
            "detected_phase": {
                "type": "string",
                "enum": PHASE_ENUM,
                "description": "Phase Wyckoff được nhận diện là khả năng cao nhất.",
            },
            "confidence": {
                "type": "integer",
                "minimum": 0,
                "maximum": 100,
                "description": "Độ tin cậy (0-100) của phase được chọn.",
            },
            "alternative_phase": {
                "type": "string",
                "enum": PHASE_ENUM + [""],
                "description": (
                    "Khả năng thứ hai nếu tình huống mơ hồ giữa 2 phase. "
                    "Để chuỗi rỗng nếu không có phương án thay thế đáng kể."
                ),
            },
            "wyckoff_events": {
                "type": "array",
                "description": (
                    "Danh sách các sự kiện/mốc Wyckoff nhận diện được trên ảnh, ví dụ: "
                    "PS, SC, AR, ST, Spring, Test, SOS, LPS, Creek/BU, PSY, BC, UT, UTAD, SOW, LPSY..."
                ),
                "items": {
                    "type": "object",
                    "properties": {
                        "event_code": {
                            "type": "string",
                            "description": "Mã sự kiện Wyckoff viết tắt, ví dụ 'SC', 'Spring', 'SOS'.",
                        },
                        "event_name_vi": {
                            "type": "string",
                            "description": "Tên sự kiện bằng tiếng Việt kèm giải nghĩa ngắn.",
                        },
                        "approx_location": {
                            "type": "string",
                            "description": (
                                "Vị trí tương đối trên ảnh, ví dụ 'giữa biểu đồ, đáy thứ 2 của nền', "
                                "'phía bên phải, gần đỉnh gần nhất'."
                            ),
                        },
                        "description": {
                            "type": "string",
                            "description": "Mô tả hành vi giá/volume tại sự kiện này bằng tiếng Việt.",
                        },
                    },
                    "required": ["event_code", "event_name_vi", "description"],
                },
            },
            "vsa_signals": {
                "type": "array",
                "description": (
                    "Các tín hiệu VSA (Volume Spread Analysis) quan trọng quan sát được: "
                    "No Demand, No Supply, Stopping Volume, Climax Volume, Effort vs Result, "
                    "Test bar, Upthrust bar, ..."
                ),
                "items": {
                    "type": "object",
                    "properties": {
                        "signal_name_vi": {
                            "type": "string",
                            "description": "Tên tín hiệu VSA bằng tiếng Việt (kèm tên gốc tiếng Anh trong ngoặc).",
                        },
                        "bar_description": {
                            "type": "string",
                            "description": "Mô tả thanh giá/nến: spread, volume, vị trí đóng cửa trong range.",
                        },
                        "interpretation": {
                            "type": "string",
                            "description": "Ý nghĩa cung/cầu suy ra từ tín hiệu này.",
                        },
                    },
                    "required": ["signal_name_vi", "bar_description", "interpretation"],
                },
            },
            "key_levels": {
                "type": "object",
                "description": "Vùng hỗ trợ/kháng cự chính quan sát được trên ảnh (nếu có).",
                "properties": {
                    "support_vi": {"type": "string"},
                    "resistance_vi": {"type": "string"},
                },
            },
            "trading_implication_vi": {
                "type": "string",
                "description": (
                    "Hàm ý về mặt hành vi giá theo Wyckoff (không phải khuyến nghị mua/bán cụ thể), "
                    "ví dụ: cần chờ xác nhận SOS trước khi kỳ vọng markup, v.v."
                ),
            },
            "risks_and_caveats_vi": {
                "type": "string",
                "description": (
                    "Các rủi ro/hạn chế của việc nhận định: dữ liệu ảnh không đủ, thiếu volume, "
                    "khung thời gian ngắn nên chưa chắc chắn, khả năng nhầm giữa tích lũy/tái tích lũy, ..."
                ),
            },
            "reasoning_summary_vi": {
                "type": "string",
                "description": "Tóm tắt lập luận tổng thể dẫn tới kết luận phase, bằng tiếng Việt, súc tích.",
            },
        },
        "required": [
            "detected_phase",
            "confidence",
            "wyckoff_events",
            "vsa_signals",
            "trading_implication_vi",
            "risks_and_caveats_vi",
            "reasoning_summary_vi",
        ],
    },
}
