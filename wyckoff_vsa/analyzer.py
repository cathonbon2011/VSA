"""Gọi Claude API (vision + tool use) để phân tích ảnh chart theo Wyckoff/VSA."""

from __future__ import annotations

import base64
import io
from dataclasses import dataclass
from pathlib import Path

from PIL import Image

from .prompts import SYSTEM_PROMPT
from .schema import WYCKOFF_ANALYSIS_TOOL

DEFAULT_MODEL = "claude-sonnet-5"
MAX_LONG_EDGE = 1568  # khuyến nghị của Anthropic để tối ưu chi phí/độ chính xác
MAX_FILE_BYTES = 5 * 1024 * 1024  # giới hạn 5MB/ảnh của API

SUPPORTED_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".gif"}


class AnalyzerError(RuntimeError):
    """Lỗi trong quá trình chuẩn bị ảnh hoặc gọi API phân tích."""


@dataclass
class PreparedImage:
    media_type: str
    base64_data: str


def _resize_if_needed(img: Image.Image) -> Image.Image:
    longest = max(img.size)
    if longest <= MAX_LONG_EDGE:
        return img
    scale = MAX_LONG_EDGE / float(longest)
    new_size = (max(1, int(img.width * scale)), max(1, int(img.height * scale)))
    return img.resize(new_size, Image.LANCZOS)


def prepare_image(path: str | Path) -> PreparedImage:
    """Đọc ảnh từ đĩa, resize nếu cần, và encode base64 để gửi lên Claude API."""
    p = Path(path)
    if not p.exists():
        raise AnalyzerError(f"Không tìm thấy file ảnh: {p}")
    if p.suffix.lower() not in SUPPORTED_SUFFIXES:
        raise AnalyzerError(
            f"Định dạng '{p.suffix}' không được hỗ trợ. "
            f"Hỗ trợ: {', '.join(sorted(SUPPORTED_SUFFIXES))}"
        )

    try:
        img = Image.open(p)
        img.load()
    except Exception as exc:  # noqa: BLE001
        raise AnalyzerError(f"Không đọc được ảnh '{p}': {exc}") from exc

    if img.mode not in ("RGB", "L"):
        img = img.convert("RGB")

    img = _resize_if_needed(img)

    buf = io.BytesIO()
    img.save(buf, format="PNG")
    data = buf.getvalue()

    if len(data) > MAX_FILE_BYTES:
        # Giảm chất lượng bằng cách nén sang JPEG nếu PNG vẫn quá lớn sau khi resize.
        buf = io.BytesIO()
        rgb_img = img.convert("RGB")
        rgb_img.save(buf, format="JPEG", quality=85)
        data = buf.getvalue()
        media_type = "image/jpeg"
    else:
        media_type = "image/png"

    if len(data) > MAX_FILE_BYTES:
        raise AnalyzerError(
            "Ảnh sau khi nén vẫn vượt quá 5MB, vui lòng dùng ảnh nhỏ hơn hoặc độ phân giải thấp hơn."
        )

    return PreparedImage(media_type=media_type, base64_data=base64.b64encode(data).decode("ascii"))


def analyze_chart(
    image_path: str | Path,
    *,
    api_key: str,
    model: str = DEFAULT_MODEL,
    extra_context: str | None = None,
) -> dict:
    """Phân tích ảnh chart và trả về dict kết quả theo schema report_wyckoff_analysis."""
    try:
        import anthropic
    except ImportError as exc:  # noqa: BLE001
        raise AnalyzerError(
            "Thiếu thư viện 'anthropic'. Cài đặt bằng: pip install -r requirements.txt"
        ) from exc

    prepared = prepare_image(image_path)
    client = anthropic.Anthropic(api_key=api_key)

    user_text = "Hãy phân tích ảnh chart này theo phương pháp Wyckoff và VSA."
    if extra_context:
        user_text += f"\n\nBối cảnh bổ sung do người dùng cung cấp: {extra_context}"

    try:
        response = client.messages.create(
            model=model,
            max_tokens=4096,
            system=SYSTEM_PROMPT,
            tools=[WYCKOFF_ANALYSIS_TOOL],
            tool_choice={"type": "tool", "name": WYCKOFF_ANALYSIS_TOOL["name"]},
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": prepared.media_type,
                                "data": prepared.base64_data,
                            },
                        },
                        {"type": "text", "text": user_text},
                    ],
                }
            ],
        )
    except anthropic.APIStatusError as exc:
        raise AnalyzerError(f"Lỗi từ Claude API ({exc.status_code}): {exc.message}") from exc
    except anthropic.APIConnectionError as exc:
        raise AnalyzerError(f"Không kết nối được tới Claude API: {exc}") from exc

    for block in response.content:
        if block.type == "tool_use" and block.name == WYCKOFF_ANALYSIS_TOOL["name"]:
            return block.input

    raise AnalyzerError("Claude không trả về kết quả phân tích có cấu trúc như mong đợi.")
