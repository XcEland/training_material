from pathlib import Path
import importlib.util
import sys


MODULE_PATH = Path(__file__).resolve().parents[1] / "03_security_assessment.py"
spec = importlib.util.spec_from_file_location("security_assessment", MODULE_PATH)
security_assessment = importlib.util.module_from_spec(spec)
assert spec.loader is not None
sys.modules["security_assessment"] = security_assessment
spec.loader.exec_module(security_assessment)


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
        message="demo message",
        evidence="demo evidence",
    )

    security_assessment.write_report([finding], output)

    assert output.exists()
    assert "demo message" in output.read_text(encoding="utf-8")
