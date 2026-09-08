"""CLI: phân tích ảnh chụp chart chứng khoán theo Wyckoff/VSA bằng Claude vision."""

from __future__ import annotations

import argparse
import json
import os
import sys

from rich.console import Console

from .analyzer import DEFAULT_MODEL, AnalyzerError, analyze_chart
from .formatter import render_result


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wyckoff-vsa",
        description=(
            "Gửi 1 ảnh chụp chart chứng khoán, nhận diện cổ phiếu đang ở phase nào "
            "theo phương pháp Wyckoff kết hợp VSA (Volume Spread Analysis)."
        ),
    )
    parser.add_argument("image", help="Đường dẫn tới file ảnh chart (png/jpg/jpeg/webp).")
    parser.add_argument(
        "--api-key",
        default=None,
        help="Anthropic API key. Nếu không truyền, sẽ đọc từ biến môi trường ANTHROPIC_API_KEY.",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"Model Claude dùng để phân tích (mặc định: {DEFAULT_MODEL}).",
    )
    parser.add_argument(
        "--context",
        default=None,
        help="Bối cảnh bổ sung (ví dụ: 'khung H4', 'đã tăng 3 tháng trước đó') để hỗ trợ phân tích.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="In kết quả dạng JSON thô ra stdout thay vì bảng đẹp (tiện để pipe sang app khác).",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    console = Console(stderr=True)

    api_key = args.api_key or os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        console.print(
            "[bold red]Lỗi:[/bold red] Chưa có Anthropic API key. "
            "Truyền --api-key hoặc export ANTHROPIC_API_KEY=sk-ant-..."
        )
        return 1

    try:
        with console.status("[bold cyan]Đang phân tích ảnh chart theo Wyckoff/VSA..."):
            result = analyze_chart(
                args.image,
                api_key=api_key,
                model=args.model,
                extra_context=args.context,
            )
    except AnalyzerError as exc:
        console.print(f"[bold red]Lỗi:[/bold red] {exc}")
        return 1
    except KeyboardInterrupt:
        console.print("\n[yellow]Đã hủy.[/yellow]")
        return 130

    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        render_result(result, console=Console())

    return 0


if __name__ == "__main__":
    sys.exit(main())
