"""
STIG Checker - Engine kiểm tra các STIG rules
"""

import os
import json
import logging
from typing import Dict, List, Optional
from datetime import datetime
from .executor import CommandExecutor


class STIGChecker:
    """Engine kiểm tra STIG compliance"""
    
    def __init__(self, executor: CommandExecutor, rules_file: str, check_scripts_dir: str):
        """
        Args:
            executor: CommandExecutor instance
            rules_file: Path to STIG rules JSON file
            check_scripts_dir: Directory containing check scripts
        """
        self.executor = executor
        self.rules_file = rules_file
        self.check_scripts_dir = check_scripts_dir
        self.logger = logging.getLogger(__name__)
        self.rules = []
        self.results = []
        
        self._load_rules()
    
    def _load_rules(self):
        """Load STIG rules from JSON file"""
        try:
            with open(self.rules_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.rules = data.get('rules', [])
            self.logger.info(f"Loaded {len(self.rules)} STIG rules")
        except Exception as e:
            self.logger.error(f"Failed to load rules: {e}")
            raise
    
    def check_rule(self, rule: Dict) -> Dict:
        """
        Kiểm tra một STIG rule
        
        Args:
            rule: Dictionary chứa thông tin rule
            
        Returns:
            Dictionary chứa kết quả kiểm tra
        """
        rule_id = rule.get('rule_id')
        check_script = rule.get('check_script')
        
        self.logger.info(f"Checking rule: {rule_id}")
        
        result = {
            'rule_id': rule_id,
            'title': rule.get('title'),
            'severity': rule.get('severity'),
            'category': rule.get('category'),
            'status': 'UNKNOWN',
            'message': '',
            'details': '',
            'timestamp': datetime.now().isoformat()
        }
        
        if not check_script:
            result['status'] = 'ERROR'
            result['message'] = 'No check script defined'
            return result
        
        script_path = os.path.join(self.check_scripts_dir, check_script)
        
        # Kiểm tra script có tồn tại không
        if not os.path.exists(script_path):
            result['status'] = 'ERROR'
            result['message'] = f'Check script not found: {script_path}'
            self.logger.error(result['message'])
            return result
        
        try:
            # Thực thi check script
            returncode, stdout, stderr = self.executor.execute_script(script_path)
            
            result['details'] = stdout.strip() if stdout else stderr.strip()
            
            # Script trả về 0 = PASS, khác 0 = FAIL
            if returncode == 0:
                result['status'] = 'PASS'
                result['message'] = 'Compliant'
            else:
                result['status'] = 'FAIL'
                result['message'] = 'Non-compliant'
            
            self.logger.info(f"Rule {rule_id}: {result['status']}")
            
        except Exception as e:
            result['status'] = 'ERROR'
            result['message'] = f'Check failed: {str(e)}'
            self.logger.error(f"Rule {rule_id} check error: {e}")
        
        return result
    
    def check_all(self, rule_ids: Optional[List[str]] = None) -> List[Dict]:
        """
        Kiểm tra tất cả rules hoặc một danh sách cụ thể
        
        Args:
            rule_ids: List of rule IDs to check (None = check all)
            
        Returns:
            List of check results
        """
        self.results = []
        
        rules_to_check = self.rules
        if rule_ids:
            rules_to_check = [r for r in self.rules if r.get('rule_id') in rule_ids]
        
        self.logger.info(f"Starting checks for {len(rules_to_check)} rules")
        
        for rule in rules_to_check:
            result = self.check_rule(rule)
            self.results.append(result)
        
        # Summary
        passed = sum(1 for r in self.results if r['status'] == 'PASS')
        failed = sum(1 for r in self.results if r['status'] == 'FAIL')
        errors = sum(1 for r in self.results if r['status'] == 'ERROR')
        
        self.logger.info(f"Check completed: {passed} PASS, {failed} FAIL, {errors} ERROR")
        
        return self.results
    
    def get_failed_rules(self) -> List[Dict]:
        """Lấy danh sách các rules FAIL"""
        return [r for r in self.results if r['status'] == 'FAIL']
    
    def get_passed_rules(self) -> List[Dict]:
        """Lấy danh sách các rules PASS"""
        return [r for r in self.results if r['status'] == 'PASS']
    
    def get_summary(self) -> Dict:
        """Lấy tổng kết kết quả"""
        if not self.results:
            return {
                'total': 0,
                'passed': 0,
                'failed': 0,
                'errors': 0,
                'compliance_rate': 0.0
            }
        
        total = len(self.results)
        passed = sum(1 for r in self.results if r['status'] == 'PASS')
        failed = sum(1 for r in self.results if r['status'] == 'FAIL')
        errors = sum(1 for r in self.results if r['status'] == 'ERROR')
        
        compliance_rate = (passed / total * 100) if total > 0 else 0.0
        
        return {
            'total': total,
            'passed': passed,
            'failed': failed,
            'errors': errors,
            'compliance_rate': round(compliance_rate, 2)
        }
    
    def export_results(self, output_file: str):
        """Export results to JSON file"""
        try:
            output_data = {
                'timestamp': datetime.now().isoformat(),
                'summary': self.get_summary(),
                'results': self.results
            }
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"Results exported to {output_file}")
        except Exception as e:
            self.logger.error(f"Failed to export results: {e}")
