"""Định dạng kết quả phân tích Wyckoff/VSA để hiển thị đẹp trên terminal."""

from __future__ import annotations

from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text

from .schema import PHASE_LABELS_VI

PHASE_COLORS = {
    "ACCUMULATION": "green",
    "REACCUMULATION": "green",
    "MARKUP": "bright_green",
    "DISTRIBUTION": "red",
    "REDISTRIBUTION": "red",
    "MARKDOWN": "bright_red",
    "UNDETERMINED": "yellow",
}


def _color_for_phase(phase: str) -> str:
    for prefix, color in PHASE_COLORS.items():
        if phase.startswith(prefix):
            return color
    return "white"


def render_result(result: dict, console: Console | None = None) -> None:
    console = console or Console()

    phase = result.get("detected_phase", "UNDETERMINED")
    phase_label = PHASE_LABELS_VI.get(phase, phase)
    color = _color_for_phase(phase)
    confidence = result.get("confidence", 0)

    header = Text()
    header.append("Phase nhận diện: ", style="bold")
    header.append(f"{phase_label}\n", style=f"bold {color}")
    header.append("Độ tin cậy: ", style="bold")
    header.append(f"{confidence}%", style=_confidence_style(confidence))

    symbol = result.get("symbol_guess") or "(không xác định)"
    timeframe = result.get("timeframe_guess") or "(không xác định)"
    has_volume = result.get("has_volume_data")
    header.append(f"\nMã/ticker: {symbol}   |   Khung thời gian: {timeframe}")
    header.append(f"\nCó dữ liệu volume: {'Có' if has_volume else 'Không'}")

    alt = result.get("alternative_phase")
    if alt:
        header.append(f"\nKhả năng thay thế: {PHASE_LABELS_VI.get(alt, alt)}", style="dim")

    console.print(Panel(header, title="[bold]Kết quả phân tích Wyckoff/VSA[/bold]", border_style=color))

    events = result.get("wyckoff_events") or []
    if events:
        table = Table(title="Các sự kiện Wyckoff nhận diện được", show_lines=True)
        table.add_column("Mã", style="bold cyan", no_wrap=True)
        table.add_column("Sự kiện", style="cyan")
        table.add_column("Vị trí", style="dim")
        table.add_column("Mô tả")
        for ev in events:
            table.add_row(
                ev.get("event_code", ""),
                ev.get("event_name_vi", ""),
                ev.get("approx_location", ""),
                ev.get("description", ""),
            )
        console.print(table)

    signals = result.get("vsa_signals") or []
    if signals:
        table = Table(title="Tín hiệu VSA (Volume Spread Analysis)", show_lines=True)
        table.add_column("Tín hiệu", style="bold magenta")
        table.add_column("Mô tả thanh giá")
        table.add_column("Diễn giải cung/cầu")
        for sig in signals:
            table.add_row(
                sig.get("signal_name_vi", ""),
                sig.get("bar_description", ""),
                sig.get("interpretation", ""),
            )
        console.print(table)

    key_levels = result.get("key_levels") or {}
    if key_levels.get("support_vi") or key_levels.get("resistance_vi"):
        console.print(
            Panel(
                f"Hỗ trợ: {key_levels.get('support_vi', '(không rõ)')}\n"
                f"Kháng cự: {key_levels.get('resistance_vi', '(không rõ)')}",
                title="Vùng giá quan trọng",
                border_style="blue",
            )
        )

    reasoning = result.get("reasoning_summary_vi")
    if reasoning:
        console.print(Panel(reasoning, title="Tóm tắt lập luận", border_style="white"))

    implication = result.get("trading_implication_vi")
    if implication:
        console.print(Panel(implication, title="Hàm ý theo Wyckoff", border_style="cyan"))

    risks = result.get("risks_and_caveats_vi")
    if risks:
        console.print(Panel(risks, title="⚠ Rủi ro / Lưu ý", border_style="yellow"))

    console.print(
        Text(
            "\nLưu ý: Đây là phân tích tự động bằng AI dựa trên MỘT ảnh tĩnh, chỉ mang tính "
            "tham khảo học thuật về phân tích kỹ thuật, KHÔNG PHẢI lời khuyên đầu tư.",
            style="italic dim",
        )
    )


def _confidence_style(confidence: int) -> str:
    if confidence >= 70:
        return "bold green"
    if confidence >= 40:
        return "bold yellow"
    return "bold red"
