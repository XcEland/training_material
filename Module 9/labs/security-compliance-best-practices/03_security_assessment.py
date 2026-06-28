"""
Module 9 hands-on exercise: security assessment scanner.

The scanner is deliberately simple. It does not replace professional static
analysis tools, but it teaches students how to look for common security risks:
- unsafe dynamic SQL in .sql files
- hardcoded passwords in Python files
- SQL f-strings or string formatting
- broad privilege references that need review
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass, asdict
from pathlib import Path


DEFAULT_RULES_PATH = Path(__file__).parent / "config" / "security_rules.json"


@dataclass(frozen=True)
class Finding:
    """One security issue or review item found in a file."""

    file_path: str
    line_number: int
    rule_name: str
    severity: str
    message: str
    evidence: str


def load_rules(path: Path = DEFAULT_RULES_PATH) -> dict:
    """Load regex-based security rules from JSON."""

    return json.loads(path.read_text(encoding="utf-8"))


def iter_target_files(root: Path) -> list[Path]:
    """Return SQL and Python files under the selected folder."""

    ignored_parts = {"__pycache__", ".pytest_cache", ".venv", "outputs"}
    targets: list[Path] = []

    for file_path in root.rglob("*"):
        if not file_path.is_file():
            continue
        if any(part in ignored_parts for part in file_path.parts):
            continue
        if file_path.suffix.lower() in {".sql", ".py"}:
            targets.append(file_path)

    return sorted(targets)


def scan_file(file_path: Path, rules: dict) -> list[Finding]:
    """Apply SQL or Python rules to one file."""

    suffix = file_path.suffix.lower()
    rule_group = "sql" if suffix == ".sql" else "python"
    findings: list[Finding] = []
    lines = file_path.read_text(encoding="utf-8", errors="ignore").splitlines()

    for line_number, line in enumerate(lines, start=1):
        for rule in rules[rule_group]["high_risk_patterns"]:
            if re.search(rule["pattern"], line, flags=re.IGNORECASE):
                findings.append(
                    Finding(
                        file_path=str(file_path),
                        line_number=line_number,
                        rule_name=rule["name"],
                        severity=rule.get("severity", "Review"),
                        message=rule["message"],
                        evidence=line.strip()[:180],
                    )
                )

    return findings


def scan_path(root: Path, rules: dict) -> list[Finding]:
    """Scan a folder and return all findings."""

    findings: list[Finding] = []
    for file_path in iter_target_files(root):
        findings.extend(scan_file(file_path, rules))
    return findings


def summarize_findings(findings: list[Finding]) -> dict:
    """Create summary counts for assessment reporting."""
    by_severity: dict[str, int] = {}
    by_rule: dict[str, int] = {}

    for finding in findings:
        by_severity[finding.severity] = by_severity.get(finding.severity, 0) + 1
        by_rule[finding.rule_name] = by_rule.get(finding.rule_name, 0) + 1

    return {
        "finding_count": len(findings),
        "by_severity": by_severity,
        "by_rule": by_rule,
        "release_recommendation": (
            "Do not release until High findings are reviewed or remediated."
            if by_severity.get("High", 0)
            else "No High findings detected by this training scanner."
        ),
    }


def write_report(findings: list[Finding], output_path: Path) -> None:
    """Write a JSON report that can be attached to review evidence."""

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(
            {
                "summary": summarize_findings(findings),
                "findings": [asdict(finding) for finding in findings],
            },
            indent=2,
        ),
        encoding="utf-8",
    )


def print_summary(findings: list[Finding]) -> None:
    """Print a short terminal summary for classroom use."""

    summary = summarize_findings(findings)
    print(f"Security findings: {summary['finding_count']}")
    print(f"By severity: {summary['by_severity']}")
    for finding in findings[:20]:
        print(
            f"- {finding.file_path}:{finding.line_number} "
            f"[{finding.severity} / {finding.rule_name}] {finding.message}"
        )
    if len(findings) > 20:
        print(f"- ... {len(findings) - 20} more findings written to the JSON report")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scan SQL and Python files for training security risks.")
    parser.add_argument("--path", default=".", help="Folder to scan.")
    parser.add_argument(
        "--output",
        default="outputs/security_assessment_report.json",
        help="JSON report output path.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root = Path(args.path).resolve()
    output_path = Path(args.output)
    rules = load_rules()
    findings = scan_path(root, rules)
    write_report(findings, output_path)
    print_summary(findings)
    print(f"Report written to: {output_path}")


if __name__ == "__main__":
    main()
