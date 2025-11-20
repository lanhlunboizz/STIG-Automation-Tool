#!/usr/bin/env python3
"""
STIG Automation Tool - Main Entry Point
Ubuntu 24.04 LTS Security Technical Implementation Guide

Pipeline:
1. Pre-remediation check
2. Generate pre-remediation report
3. Auto remediation (if enabled)
4. Re-validation check
5. Generate post-remediation report
"""

import os
import sys
import argparse
import yaml
import logging
import socket
from datetime import datetime

from lib import (
    CommandExecutor,
    STIGChecker,
    STIGRemediator,
    STIGReporter,
    setup_logging
)


def load_config(config_file: str) -> dict:
    """Load configuration from YAML file"""
    with open(config_file, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description='STIG Automation Tool for Ubuntu 24.04 LTS',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run locally with auto-remediation
  python main.py --mode local --auto-remediate
  
  # Run via SSH, check only
  python main.py --mode ssh --host 192.168.1.100 --user ubuntu --key ~/.ssh/id_rsa --check-only
  
  # Run specific rules
  python main.py --mode local --rules UBTU-24-010001,UBTU-24-010002
        """
    )
    
    parser.add_argument(
        '--mode',
        choices=['local', 'ssh'],
        default='local',
        help='Execution mode (default: local)'
    )
    
    parser.add_argument(
        '--host',
        help='SSH host (required if mode=ssh)'
    )
    
    parser.add_argument(
        '--user',
        help='SSH username (required if mode=ssh)'
    )
    
    parser.add_argument(
        '--key',
        help='SSH private key file'
    )
    
    parser.add_argument(
        '--password',
        help='SSH password (if not using key)'
    )
    
    parser.add_argument(
        '--port',
        type=int,
        default=22,
        help='SSH port (default: 22)'
    )
    
    parser.add_argument(
        '--check-only',
        action='store_true',
        help='Only run checks, no remediation'
    )
    
    parser.add_argument(
        '--auto-remediate',
        action='store_true',
        help='Automatically remediate failed checks'
    )
    
    parser.add_argument(
        '--rules',
        help='Comma-separated list of rule IDs to check (default: all)'
    )
    
    parser.add_argument(
        '--config',
        default='config/settings.yaml',
        help='Configuration file (default: config/settings.yaml)'
    )
    
    parser.add_argument(
        '--log-level',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
        default='INFO',
        help='Logging level (default: INFO)'
    )
    
    parser.add_argument(
        '--no-backup',
        action='store_true',
        help='Disable backup before remediation'
    )
    
    return parser.parse_args()


def main():
    """Main pipeline"""
    # Parse arguments
    args = parse_arguments()
    
    # Load configuration
    if os.path.exists(args.config):
        config = load_config(args.config)
    else:
        print(f"Warning: Config file {args.config} not found, using defaults")
        config = {}
    
    # Setup paths
    base_dir = os.path.dirname(os.path.abspath(__file__))
    reports_dir = os.path.join(base_dir, config.get('paths', {}).get('reports_dir', 'reports'))
    logs_dir = os.path.join(base_dir, config.get('paths', {}).get('logs_dir', 'logs'))
    rules_file = os.path.join(base_dir, config.get('paths', {}).get('rules_file', 'config/stig_rules.json'))
    check_scripts_dir = os.path.join(base_dir, config.get('paths', {}).get('check_scripts_dir', 'scripts/checks'))
    remediation_scripts_dir = os.path.join(base_dir, config.get('paths', {}).get('remediation_scripts_dir', 'scripts/remediation'))
    
    # Create directories
    os.makedirs(reports_dir, exist_ok=True)
    os.makedirs(logs_dir, exist_ok=True)
    
    # Setup logging
    logger = setup_logging(
        logs_dir,
        level=args.log_level,
        console=True,
        file=True
    )
    
    logger.info("=" * 80)
    logger.info("STIG Automation Tool - Ubuntu 24.04 LTS")
    logger.info("=" * 80)
    
    # Validate SSH parameters
    if args.mode == 'ssh':
        if not args.host or not args.user:
            logger.error("SSH mode requires --host and --user parameters")
            sys.exit(1)
        if not args.key and not args.password:
            logger.error("SSH mode requires either --key or --password")
            sys.exit(1)
    
    # Setup SSH config
    ssh_config = None
    if args.mode == 'ssh':
        ssh_config = {
            'host': args.host,
            'port': args.port,
            'username': args.user,
            'key_file': args.key,
            'password': args.password
        }
        logger.info(f"SSH Mode: {args.user}@{args.host}:{args.port}")
    else:
        logger.info("Local Mode")
    
    # Parse rule IDs
    rule_ids = None
    if args.rules:
        rule_ids = [r.strip() for r in args.rules.split(',')]
        logger.info(f"Checking specific rules: {', '.join(rule_ids)}")
    
    try:
        # Initialize executor
        logger.info("Initializing command executor...")
        with CommandExecutor(mode=args.mode, ssh_config=ssh_config) as executor:
            
            # Get hostname
            if args.mode == 'local':
                hostname = socket.gethostname()
            else:
                _, stdout, _ = executor.execute('hostname')
                hostname = stdout.strip()
            
            logger.info(f"Target hostname: {hostname}")
            
            # Metadata
            metadata = {
                'hostname': hostname,
                'mode': args.mode,
                'timestamp': datetime.now().isoformat(),
                'auto_remediate': args.auto_remediate or not args.check_only
            }
            
            # ========================================
            # PHASE 1: PRE-REMEDIATION CHECK
            # ========================================
            logger.info("")
            logger.info("=" * 80)
            logger.info("PHASE 1: Pre-Remediation Check")
            logger.info("=" * 80)
            
            checker = STIGChecker(executor, rules_file, check_scripts_dir)
            pre_check_results = checker.check_all(rule_ids)
            
            pre_summary = checker.get_summary()
            logger.info(f"Pre-check Summary: {pre_summary['passed']} PASS, {pre_summary['failed']} FAIL, {pre_summary['errors']} ERROR")
            logger.info(f"Initial Compliance Rate: {pre_summary['compliance_rate']}%")
            
            # ========================================
            # PHASE 2: REMEDIATION
            # ========================================
            remediation_results = []
            post_check_results = []
            
            if not args.check_only and (args.auto_remediate or config.get('behavior', {}).get('auto_remediate', False)):
                logger.info("")
                logger.info("=" * 80)
                logger.info("PHASE 2: Auto Remediation")
                logger.info("=" * 80)
                
                failed_checks = checker.get_failed_rules()
                
                if not failed_checks:
                    logger.info("No failed checks to remediate")
                else:
                    logger.info(f"Found {len(failed_checks)} failed checks")
                    
                    backup = not args.no_backup
                    max_retry = config.get('behavior', {}).get('max_retry', 3)
                    
                    remediator = STIGRemediator(
                        executor,
                        rules_file,
                        remediation_scripts_dir,
                        backup=backup
                    )
                    
                    remediation_results = remediator.remediate_failed_rules(
                        failed_checks,
                        max_retry=max_retry
                    )
                    
                    rem_summary = remediator.get_summary()
                    logger.info(f"Remediation Summary: {rem_summary['success']} SUCCESS, {rem_summary['failed']} FAILED")
                    logger.info(f"Remediation Success Rate: {rem_summary['success_rate']}%")
                    
                    # ========================================
                    # PHASE 3: RE-VALIDATION
                    # ========================================
                    if config.get('behavior', {}).get('re_validate_after_fix', True):
                        logger.info("")
                        logger.info("=" * 80)
                        logger.info("PHASE 3: Re-Validation Check")
                        logger.info("=" * 80)
                        
                        post_checker = STIGChecker(executor, rules_file, check_scripts_dir)
                        post_check_results = post_checker.check_all(rule_ids)
                        
                        post_summary = post_checker.get_summary()
                        logger.info(f"Post-check Summary: {post_summary['passed']} PASS, {post_summary['failed']} FAIL, {post_summary['errors']} ERROR")
                        logger.info(f"Final Compliance Rate: {post_summary['compliance_rate']}%")
                        
                        # Calculate improvement
                        improvement = post_summary['compliance_rate'] - pre_summary['compliance_rate']
                        if improvement > 0:
                            logger.info(f"✓ Compliance improved by {improvement:.2f}%")
                        elif improvement < 0:
                            logger.warning(f"⚠ Compliance decreased by {abs(improvement):.2f}%")
                        else:
                            logger.info("No change in compliance rate")
            else:
                logger.info("Skipping remediation (check-only mode)")
                post_check_results = pre_check_results  # Use pre-check results
            
            # ========================================
            # PHASE 4: GENERATE REPORTS
            # ========================================
            logger.info("")
            logger.info("=" * 80)
            logger.info("PHASE 4: Generate Reports")
            logger.info("=" * 80)
            
            reporter = STIGReporter(reports_dir)
            
            # Generate HTML report
            html_report = reporter.generate_html_report(
                pre_check_results,
                remediation_results,
                post_check_results,
                metadata
            )
            logger.info(f"HTML Report: {html_report}")
            
            # Generate JSON report
            json_report = reporter.generate_json_report(
                pre_check_results,
                remediation_results,
                post_check_results,
                metadata
            )
            logger.info(f"JSON Report: {json_report}")
            
            # ========================================
            # SUMMARY
            # ========================================
            logger.info("")
            logger.info("=" * 80)
            logger.info("EXECUTION SUMMARY")
            logger.info("=" * 80)
            logger.info(f"Target: {hostname}")
            logger.info(f"Mode: {args.mode}")
            logger.info(f"Rules Checked: {len(pre_check_results)}")
            
            if remediation_results:
                logger.info(f"Remediations Applied: {len(remediation_results)}")
            
            if post_check_results != pre_check_results:
                final_summary = STIGChecker(executor, rules_file, check_scripts_dir).get_summary() if not post_check_results else post_summary
                logger.info(f"Final Compliance: {final_summary['compliance_rate']}%")
            else:
                logger.info(f"Compliance Rate: {pre_summary['compliance_rate']}%")
            
            logger.info(f"Reports: {reports_dir}")
            logger.info(f"Logs: {logs_dir}")
            logger.info("=" * 80)
            logger.info("✓ Execution completed successfully")
            
    except KeyboardInterrupt:
        logger.warning("\n⚠ Execution interrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.error(f"✗ Execution failed: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
