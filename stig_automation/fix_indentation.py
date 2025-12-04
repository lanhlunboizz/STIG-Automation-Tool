#!/usr/bin/env python3
"""Fix indentation issues in main.py"""

def fix_indentation(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace tabs with 4 spaces
    content = content.replace('\t', '    ')
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed indentation in {filename}")

if __name__ == '__main__':
    fix_indentation('main.py')
