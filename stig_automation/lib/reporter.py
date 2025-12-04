"""
Report Generator - Tạo báo cáo HTML/JSON cho STIG compliance
"""

import os
import json
import logging
from datetime import datetime
from typing import Dict, List
from jinja2 import Template


class STIGReporter:
    """Tạo báo cáo STIG compliance"""
    
    def __init__(self, reports_dir: str):
        """
        Args:
            reports_dir: Directory to save reports
        """
        self.reports_dir = reports_dir
        self.logger = logging.getLogger(__name__)
        
        # Create reports directory if not exists
        os.makedirs(reports_dir, exist_ok=True)
    
    def generate_html_report(self, 
                           pre_check_results: List[Dict],
                           remediation_results: List[Dict],
                           post_check_results: List[Dict],
                           metadata: Dict) -> str:
        """
        Tạo báo cáo HTML
        
        Args:
            pre_check_results: Kết quả kiểm tra ban đầu
            remediation_results: Kết quả remediation
            post_check_results: Kết quả kiểm tra sau remediation
            metadata: Thông tin metadata (hostname, timestamp, etc.)
            
        Returns:
            Path to generated HTML report
        """
        template = self._get_html_template()
        
        # Calculate summaries
        pre_summary = self._calculate_summary(pre_check_results)
        post_summary = self._calculate_summary(post_check_results)
        remediation_summary = self._calculate_remediation_summary(remediation_results)
        
        # Combine data
        combined_results = self._combine_results(
            pre_check_results,
            remediation_results,
            post_check_results
        )
        
        # Render template
        html_content = template.render(
            metadata=metadata,
            pre_summary=pre_summary,
            post_summary=post_summary,
            remediation_summary=remediation_summary,
            results=combined_results,
            timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        )
        
        # Save report
        filename = f"stig_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
        filepath = os.path.join(self.reports_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        # Fix permissions (make readable/writable by owner and group)
        try:
            os.chmod(filepath, 0o664)
        except Exception as e:
            self.logger.warning(f"Could not change file permissions: {e}")
        
        self.logger.info(f"HTML report generated: {filepath}")
        return filepath
    
    def generate_json_report(self,
                           pre_check_results: List[Dict],
                           remediation_results: List[Dict],
                           post_check_results: List[Dict],
                           metadata: Dict) -> str:
        """
        Tạo báo cáo JSON
        
        Returns:
            Path to generated JSON report
        """
        report_data = {
            'metadata': metadata,
            'timestamp': datetime.now().isoformat(),
            'pre_check': {
                'summary': self._calculate_summary(pre_check_results),
                'results': pre_check_results
            },
            'remediation': {
                'summary': self._calculate_remediation_summary(remediation_results),
                'results': remediation_results
            },
            'post_check': {
                'summary': self._calculate_summary(post_check_results),
                'results': post_check_results
            }
        }
        
        filename = f"stig_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        filepath = os.path.join(self.reports_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        # Fix permissions (make readable/writable by owner and group)
        try:
            os.chmod(filepath, 0o664)
        except Exception as e:
            self.logger.warning(f"Could not change file permissions: {e}")
        
        self.logger.info(f"JSON report generated: {filepath}")
        return filepath
    
    def _calculate_summary(self, results: List[Dict]) -> Dict:
        """Tính toán summary từ check results"""
        if not results:
            return {
                'total': 0,
                'passed': 0,
                'failed': 0,
                'errors': 0,
                'compliance_rate': 0.0
            }
        
        total = len(results)
        passed = sum(1 for r in results if r.get('status') == 'PASS')
        failed = sum(1 for r in results if r.get('status') == 'FAIL')
        errors = sum(1 for r in results if r.get('status') == 'ERROR')
        
        compliance_rate = (passed / total * 100) if total > 0 else 0.0
        
        return {
            'total': total,
            'passed': passed,
            'failed': failed,
            'errors': errors,
            'compliance_rate': round(compliance_rate, 2)
        }
    
    def _calculate_remediation_summary(self, results: List[Dict]) -> Dict:
        """Tính toán summary từ remediation results"""
        if not results:
            return {
                'total': 0,
                'success': 0,
                'failed': 0,
                'errors': 0,
                'success_rate': 0.0
            }
        
        total = len(results)
        success = sum(1 for r in results if r.get('status') == 'SUCCESS')
        failed = sum(1 for r in results if r.get('status') == 'FAILED')
        errors = sum(1 for r in results if r.get('status') == 'ERROR')
        
        success_rate = (success / total * 100) if total > 0 else 0.0
        
        return {
            'total': total,
            'success': success,
            'failed': failed,
            'errors': errors,
            'success_rate': round(success_rate, 2)
        }
    
    def _combine_results(self,
                        pre_check: List[Dict],
                        remediation: List[Dict],
                        post_check: List[Dict]) -> List[Dict]:
        """Kết hợp các kết quả lại"""
        combined = []
        
        # Create lookup dictionaries
        remediation_dict = {r.get('rule_id'): r for r in remediation}
        post_check_dict = {r.get('rule_id'): r for r in post_check}
        
        for pre_result in pre_check:
            rule_id = pre_result.get('rule_id')
            
            combined_item = {
                'rule_id': rule_id,
                'title': pre_result.get('title'),
                'severity': pre_result.get('severity'),
                'category': pre_result.get('category'),
                'pre_check_status': pre_result.get('status'),
                'pre_check_message': pre_result.get('message'),
                'remediation_status': None,
                'remediation_message': None,
                'post_check_status': None,
                'post_check_message': None,
                'improved': False
            }
            
            # Add remediation info if exists
            if rule_id in remediation_dict:
                rem_result = remediation_dict[rule_id]
                combined_item['remediation_status'] = rem_result.get('status')
                combined_item['remediation_message'] = rem_result.get('message')
            
            # Add post-check info if exists
            if rule_id in post_check_dict:
                post_result = post_check_dict[rule_id]
                combined_item['post_check_status'] = post_result.get('status')
                combined_item['post_check_message'] = post_result.get('message')
                
                # Check if improved
                if pre_result.get('status') == 'FAIL' and post_result.get('status') == 'PASS':
                    combined_item['improved'] = True
            
            combined.append(combined_item)
        
        return combined
    
    def _get_html_template(self) -> Template:
        """Get HTML template for report"""
        template_str = """
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>STIG Compliance Report - Ubuntu 24.04 LTS</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        .container { 
            max-width: 1400px; 
            margin: 0 auto; 
            background: white;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 8px 8px 0 0;
        }
        .header h1 { margin-bottom: 10px; }
        .header p { opacity: 0.9; }
        .metadata {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            padding: 20px 30px;
            background: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
        }
        .metadata-item { }
        .metadata-item strong { 
            display: block; 
            color: #666;
            font-size: 12px;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            padding: 30px;
        }
        .summary-card {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
        }
        .summary-card h3 {
            color: #495057;
            margin-bottom: 15px;
            font-size: 16px;
            text-transform: uppercase;
        }
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        .stat {
            padding: 10px;
            background: #f8f9fa;
            border-radius: 5px;
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #212529;
        }
        .stat-label {
            font-size: 12px;
            color: #6c757d;
            text-transform: uppercase;
        }
        .compliance-rate {
            font-size: 32px;
            font-weight: bold;
            text-align: center;
            margin-top: 15px;
            padding: 15px;
            background: #e7f3ff;
            border-radius: 5px;
        }
        .results-section {
            padding: 30px;
        }
        .results-section h2 {
            margin-bottom: 20px;
            color: #212529;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }
        th {
            background: #495057;
            color: white;
            padding: 12px;
            text-align: left;
            font-size: 14px;
            position: sticky;
            top: 0;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
            font-size: 14px;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status-pass { background: #d4edda; color: #155724; }
        .status-fail { background: #f8d7da; color: #721c24; }
        .status-error { background: #fff3cd; color: #856404; }
        .status-success { background: #d1ecf1; color: #0c5460; }
        .severity-high { color: #dc3545; font-weight: bold; }
        .severity-medium { color: #fd7e14; font-weight: bold; }
        .severity-low { color: #ffc107; font-weight: bold; }
        .improved { background: #d4edda !important; }
        .footer {
            padding: 20px 30px;
            text-align: center;
            background: #f8f9fa;
            border-top: 1px solid #dee2e6;
            color: #6c757d;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 STIG Compliance Report</h1>
            <p>Ubuntu 24.04 LTS Security Technical Implementation Guide</p>
        </div>
        
        <div class="metadata">
            <div class="metadata-item">
                <strong>Hostname</strong>
                <div>{{ metadata.hostname }}</div>
            </div>
            <div class="metadata-item">
                <strong>Report Date</strong>
                <div>{{ timestamp }}</div>
            </div>
            <div class="metadata-item">
                <strong>Execution Mode</strong>
                <div>{{ metadata.mode }}</div>
            </div>
            <div class="metadata-item">
                <strong>Total Rules</strong>
                <div>{{ pre_summary.total }}</div>
            </div>
        </div>
        
        <div class="summary">
            <div class="summary-card">
                <h3>📋 Pre-Remediation Check</h3>
                <div class="summary-stats">
                    <div class="stat">
                        <div class="stat-value" style="color: #28a745;">{{ pre_summary.passed }}</div>
                        <div class="stat-label">Passed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color: #dc3545;">{{ pre_summary.failed }}</div>
                        <div class="stat-label">Failed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color: #ffc107;">{{ pre_summary.errors }}</div>
                        <div class="stat-label">Errors</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value">{{ pre_summary.total }}</div>
                        <div class="stat-label">Total</div>
                    </div>
                </div>
                <div class="compliance-rate" style="color: {% if pre_summary.compliance_rate >= 80 %}#28a745{% elif pre_summary.compliance_rate >= 50 %}#ffc107{% else %}#dc3545{% endif %};">
                    {{ pre_summary.compliance_rate }}%
                </div>
            </div>
            
            <div class="summary-card">
                <h3>🔧 Remediation</h3>
                <div class="summary-stats">
                    <div class="stat">
                        <div class="stat-value" style="color: #17a2b8;">{{ remediation_summary.success }}</div>
                        <div class="stat-label">Success</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color: #dc3545;">{{ remediation_summary.failed }}</div>
                        <div class="stat-label">Failed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color: #ffc107;">{{ remediation_summary.errors }}</div>
                        <div class="stat-label">Errors</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value">{{ remediation_summary.total }}</div>
                        <div class="stat-label">Total</div>
                    </div>
                </div>
                <div class="compliance-rate" style="color: {% if remediation_summary.success_rate >= 80 %}#17a2b8{% elif remediation_summary.success_rate >= 50 %}#ffc107{% else %}#dc3545{% endif %};">
                    {{ remediation_summary.success_rate }}%
                </div>
            </div>
            
            <div class="summary-card">
                <h3>✅ Post-Remediation Check</h3>
                <div class="summary-stats">
                    <div class="stat">
                        <div class="stat-value" style="color: #28a745;">{{ post_summary.passed }}</div>
                        <div class="stat-label">Passed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color: #dc3545;">{{ post_summary.failed }}</div>
                        <div class="stat-label">Failed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" style="color: #ffc107;">{{ post_summary.errors }}</div>
                        <div class="stat-label">Errors</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value">{{ post_summary.total }}</div>
                        <div class="stat-label">Total</div>
                    </div>
                </div>
                <div class="compliance-rate" style="color: {% if post_summary.compliance_rate >= 80 %}#28a745{% elif post_summary.compliance_rate >= 50 %}#ffc107{% else %}#dc3545{% endif %};">
                    {{ post_summary.compliance_rate }}%
                </div>
            </div>
        </div>
        
        <div class="results-section">
            <h2>📊 Detailed Results</h2>
            <table>
                <thead>
                    <tr>
                        <th>Rule ID</th>
                        <th>Title</th>
                        <th>Severity</th>
                        <th>Pre-Check</th>
                        <th>Remediation</th>
                        <th>Post-Check</th>
                    </tr>
                </thead>
                <tbody>
                    {% for result in results %}
                    <tr class="{% if result.improved %}improved{% endif %}">
                        <td><strong>{{ result.rule_id }}</strong></td>
                        <td>{{ result.title }}</td>
                        <td class="severity-{{ result.severity }}">{{ result.severity }}</td>
                        <td>
                            <span class="status-badge status-{{ result.pre_check_status|lower }}">
                                {{ result.pre_check_status }}
                            </span>
                        </td>
                        <td>
                            {% if result.remediation_status %}
                            <span class="status-badge status-{{ result.remediation_status|lower }}">
                                {{ result.remediation_status }}
                            </span>
                            {% else %}
                            <span style="color: #6c757d;">N/A</span>
                            {% endif %}
                        </td>
                        <td>
                            {% if result.post_check_status %}
                            <span class="status-badge status-{{ result.post_check_status|lower }}">
                                {{ result.post_check_status }}
                            </span>
                            {% if result.improved %}
                                <span style="color: #28a745;">✓ Improved</span>
                            {% endif %}
                            {% else %}
                            <span style="color: #6c757d;">N/A</span>
                            {% endif %}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
        
        <div class="footer">
            <p>Generated by STIG Automation Tool | {{ timestamp }}</p>
            <p>Ubuntu 24.04 LTS Security Technical Implementation Guide</p>
        </div>
    </div>
</body>
</html>
        """
        return Template(template_str)
