import json
import re
from pathlib import Path
from datetime import datetime, timedelta

TARGET_DIR = Path.home() / "etc"
LOOKBACK_LIMIT = 7 

def get_tasks(file_path):
    if not file_path or not file_path.exists():
        return []
    
    tasks = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            nb = json.load(f)
            for cell in nb.get('cells', []):
                if cell.get('cell_type') == 'markdown':
                    src = cell.get('source', [])
                    lines = src if isinstance(src, list) else src.splitlines()
                    # Grab lines starting with an empty checkbox
                    tasks.extend([line.strip() for line in lines if re.match(r'^\s*-\s*\[\s*\]', line)])
    except (json.JSONDecodeError, OSError):
        pass
    return tasks

def create_nb(path, tasks):
    date_header = datetime.now().strftime("%B %d, %Y")
    task_text = "\n".join(tasks) if tasks else "*No tasks carried over.*"
    
    content = {
        "cells": [
            {"cell_type": "markdown", "metadata": {}, "source": [f"# {date_header}\n"]},
            {"cell_type": "markdown", "metadata": {}, "source": [f"## Todo\n\n", f"{task_text}\n"]}
        ],
        "metadata": {
            "kernelspec": {"display_name": "Python 3", "name": "python3"},
            "language_info": {"name": "python"}
        },
        "nbformat": 4, "nbformat_minor": 4
    }
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=4)

# Execute
today_path = TARGET_DIR / f"{datetime.now().strftime('%Y-%m-%d')}.ipynb"

if today_path.exists():
    print(f"File {today_path.name} already exists.")
else:
    # Look for the most recent file within the lookback limit
    source_file = next((TARGET_DIR / f"{(datetime.now() - timedelta(days=i)).strftime('%Y-%m-%d')}.ipynb" 
                       for i in range(1, LOOKBACK_LIMIT + 1) 
                       if (TARGET_DIR / f"{(datetime.now() - timedelta(days=i)).strftime('%Y-%m-%d')}.ipynb").exists()), None)
    
    create_nb(today_path, get_tasks(source_file))
    print(f"Created {today_path.name}")
