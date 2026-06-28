from pathlib import Path
import importlib.util
import sys


MODULE_PATH = Path(__file__).resolve().parents[1] / "03_security_assessment.py"
spec = importlib.util.spec_from_file_location("security_assessment", MODULE_PATH)
security_assessment = importlib.util.module_from_spec(spec)
assert spec.loader is not None
sys.modules["security_assessment"] = security_assessment
spec.loader.exec_module(security_assessment)


def load_module(filename: str, module_name: str):
    module_path = Path(__file__).resolve().parents[1] / filename
    module_spec = importlib.util.spec_from_file_location(module_name, module_path)
    module = importlib.util.module_from_spec(module_spec)
    assert module_spec.loader is not None
    module_spec.loader.exec_module(module)
    return module


def test_scanner_detects_hardcoded_password(tmp_path):
    sample = tmp_path / "bad_script.py"
    sample.write_text("password = 'PlainText123'\n", encoding="utf-8")

    findings = security_assessment.scan_path(tmp_path, security_assessment.load_rules())

    assert any(finding.rule_name == "hardcoded_password" for finding in findings)


def test_scanner_detects_unsafe_dynamic_sql(tmp_path):
    sample = tmp_path / "bad_proc.sql"
    sample.write_text("EXEC (@Sql);\n", encoding="utf-8")

    findings = security_assessment.scan_path(tmp_path, security_assessment.load_rules())

    assert any(finding.rule_name == "dynamic_sql_exec_string" for finding in findings)


def test_write_report_creates_json(tmp_path):
    output = tmp_path / "report.json"
    finding = security_assessment.Finding(
        file_path="example.py",
        line_number=1,
        rule_name="demo",
        severity="High",
        message="demo message",
        evidence="demo evidence",
    )

    security_assessment.write_report([finding], output)

    assert output.exists()
    assert "demo message" in output.read_text(encoding="utf-8")


def test_summary_counts_findings_by_severity(tmp_path):
    sample = tmp_path / "bad_script.py"
    sample.write_text("password = 'PlainText123'\n", encoding="utf-8")

    findings = security_assessment.scan_path(tmp_path, security_assessment.load_rules())
    summary = security_assessment.summarize_findings(findings)

    assert summary["finding_count"] == 1
    assert summary["by_severity"]["High"] == 1


def test_audit_evidence_pack_has_events():
    audit_demo = load_module("04_audit_compliance_evidence_demo.py", "audit_demo_test")

    events = audit_demo.build_audit_events()
    evidence_pack = audit_demo.build_evidence_pack(events)

    assert evidence_pack["event_count"] >= 3
    assert "privacy_note" in evidence_pack


def test_roi_calculator_returns_positive_roi():
    roi_demo = load_module("05_kpi_roi_calculator.py", "roi_demo_test")

    result = roi_demo.calculate_roi(
        hours_saved_per_month=40,
        average_hourly_cost=35,
        annual_operating_cost=2000,
        implementation_cost=6000,
    )

    assert result["annual_benefit"] == 16800
    assert result["roi_percentage"] > 0
