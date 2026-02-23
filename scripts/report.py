#!/usr/bin/env python3
"""Generate synthesis area/power summary tables for sv-async-fifo-cdc.

Inputs:
- syntesis/logical/results/BITS*_SIZE*/reports/async_fifo_area.rpt
- syntesis/power/results/BITS*_SIZE*/power_evaluation.txt

Outputs (default: syntesis/reports):
- area_table.csv
- power_table.csv
- summary.md
"""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple


CFG_RE = re.compile(r"^BITS(?P<bits>\d+)_SIZE(?P<size>\d+)$")


def parse_cfg_tag(name: str) -> Optional[Tuple[int, int, str]]:
    m = CFG_RE.match(name)
    if not m:
        return None
    bits = int(m.group("bits"))
    size = int(m.group("size"))
    return bits, size, name


def parse_area_report(path: Path) -> Optional[Dict[str, float]]:
    """Parse async_fifo top row from Genus area report."""
    row_re = re.compile(
        r"^\s*async_fifo\s+(?:\S+\s+)?"
        r"(?P<cell_count>\d+)\s+"
        r"(?P<cell_area>[0-9]+(?:\.[0-9]+)?)\s+"
        r"(?P<net_area>[0-9]+(?:\.[0-9]+)?)\s+"
        r"(?P<total_area>[0-9]+(?:\.[0-9]+)?)\s*$"
    )
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = row_re.match(line)
        if m:
            return {
                "cell_count": float(m.group("cell_count")),
                "cell_area_um2": float(m.group("cell_area")),
                "net_area_um2": float(m.group("net_area")),
                "total_area_um2": float(m.group("total_area")),
            }
    return None


def parse_power_report(path: Path) -> Optional[Dict[str, float]]:
    """Parse Subtotal row from Genus power report."""
    subtotal_re = re.compile(
        r"^\s*Subtotal\s+"
        r"(?P<leakage>[0-9.eE+-]+)\s+"
        r"(?P<internal>[0-9.eE+-]+)\s+"
        r"(?P<switching>[0-9.eE+-]+)\s+"
        r"(?P<total>[0-9.eE+-]+)\s+"
    )
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = subtotal_re.match(line)
        if m:
            return {
                "leakage_mw": float(m.group("leakage")),
                "internal_mw": float(m.group("internal")),
                "switching_mw": float(m.group("switching")),
                "total_mw": float(m.group("total")),
            }
    return None


def collect_area_rows(repo_root: Path) -> List[Dict[str, object]]:
    rows: List[Dict[str, object]] = []
    base = repo_root / "syntesis" / "logical" / "results"
    for cfg_dir in sorted(base.glob("BITS*_SIZE*")):
        cfg = parse_cfg_tag(cfg_dir.name)
        if cfg is None:
            continue
        bits, size, tag = cfg
        rpt = cfg_dir / "reports" / "async_fifo_area.rpt"
        if not rpt.exists():
            continue
        parsed = parse_area_report(rpt)
        if parsed is None:
            continue
        row: Dict[str, object] = {"cfg": tag, "bits": bits, "size": size}
        row.update(parsed)
        rows.append(row)
    rows.sort(key=lambda r: (int(r["bits"]), int(r["size"])))
    return rows


def collect_power_rows(repo_root: Path) -> List[Dict[str, object]]:
    rows: List[Dict[str, object]] = []
    base = repo_root / "syntesis" / "power" / "results"
    for cfg_dir in sorted(base.glob("BITS*_SIZE*")):
        cfg = parse_cfg_tag(cfg_dir.name)
        if cfg is None:
            continue
        bits, size, tag = cfg
        rpt = cfg_dir / "power_evaluation.txt"
        if not rpt.exists():
            continue
        parsed = parse_power_report(rpt)
        if parsed is None:
            continue
        row: Dict[str, object] = {"cfg": tag, "bits": bits, "size": size}
        row.update(parsed)
        rows.append(row)
    rows.sort(key=lambda r: (int(r["bits"]), int(r["size"])))
    return rows


def write_csv(path: Path, rows: List[Dict[str, object]], columns: Iterable[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(columns))
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def fmt_num(v: object, ndigits: int = 3) -> str:
    if isinstance(v, float):
        return f"{v:.{ndigits}f}"
    return str(v)


def to_markdown_table(rows: List[Dict[str, object]], columns: List[str], ndigits: int = 3) -> str:
    if not rows:
        return "_No data found._\n"

    headers = columns
    md = []
    md.append("| " + " | ".join(headers) + " |")
    md.append("| " + " | ".join(["---"] * len(headers)) + " |")
    for row in rows:
        md.append("| " + " | ".join(fmt_num(row.get(c, ""), ndigits) for c in headers) + " |")
    md.append("")
    return "\n".join(md)


def write_summary_md(path: Path, area_rows: List[Dict[str, object]], power_rows: List[Dict[str, object]]) -> None:
    area_cols = ["cfg", "bits", "size", "cell_count", "cell_area_um2", "net_area_um2", "total_area_um2"]
    power_cols = ["cfg", "bits", "size", "leakage_mw", "internal_mw", "switching_mw", "total_mw"]

    text = []
    text.append("# Synthesis Summary")
    text.append("")
    text.append("## Area Table")
    text.append("")
    text.append(to_markdown_table(area_rows, area_cols, ndigits=3))
    text.append("## Power Table")
    text.append("")
    text.append(to_markdown_table(power_rows, power_cols, ndigits=6))

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(text), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate area and power tables from synthesis outputs.")
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Repository root (default: inferred from script location).",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=None,
        help="Output directory (default: <repo>/syntesis/reports).",
    )
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    out_dir = args.out_dir.resolve() if args.out_dir else (repo_root / "syntesis" / "reports")

    area_rows = collect_area_rows(repo_root)
    power_rows = collect_power_rows(repo_root)

    area_cols = ["cfg", "bits", "size", "cell_count", "cell_area_um2", "net_area_um2", "total_area_um2"]
    power_cols = ["cfg", "bits", "size", "leakage_mw", "internal_mw", "switching_mw", "total_mw"]

    write_csv(out_dir / "area_table.csv", area_rows, area_cols)
    write_csv(out_dir / "power_table.csv", power_rows, power_cols)
    write_summary_md(out_dir / "summary.md", area_rows, power_rows)

    print(f"[OK] Wrote {out_dir / 'area_table.csv'}")
    print(f"[OK] Wrote {out_dir / 'power_table.csv'}")
    print(f"[OK] Wrote {out_dir / 'summary.md'}")
    print(f"[INFO] area rows: {len(area_rows)}")
    print(f"[INFO] power rows: {len(power_rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
