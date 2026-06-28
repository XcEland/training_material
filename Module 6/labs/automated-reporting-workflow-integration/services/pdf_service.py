"""Optional PDF generation for rendered HTML reports."""

from __future__ import annotations

from typing import Any

from reports.common import ReportArtifact


def generate_pdf_reports(artifacts: list[ReportArtifact], config: dict[str, Any]) -> str:
    """Create PDFs when WeasyPrint is installed.

    We keep this optional because WeasyPrint can require system libraries on
    some machines. The HTML reports are already print-ready for beginner labs.
    """
    try:
        from weasyprint import HTML
    except Exception:
        for artifact in artifacts:
            artifact.pdf_status = "SkippedPdfDependencyMissing"
        return "SkippedPdfDependencyMissing"

    config["paths"]["pdf"].mkdir(parents=True, exist_ok=True)
    for artifact in artifacts:
        pdf_path = config["paths"]["pdf"] / artifact.html_path.with_suffix(".pdf").name
        HTML(filename=str(artifact.html_path)).write_pdf(str(pdf_path))
        artifact.pdf_path = pdf_path
        artifact.pdf_status = "Generated"
    return "Generated"
