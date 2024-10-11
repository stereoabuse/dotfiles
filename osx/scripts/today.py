import json
import os
from datetime import datetime, timedelta

TARGET_DIR = "/Users/yourname/etc"

today = datetime.now()
today_str = today.strftime("%m_%d_%y")

most_recent_file_date = today - timedelta(days=1)

while True:
    most_recent_file_str = most_recent_file_date.strftime("%m_%d_%y")
    most_recent_file = os.path.join(TARGET_DIR, f"{most_recent_file_str}.ipynb")
    if os.path.isfile(most_recent_file):
        break
    most_recent_file_date -= timedelta(days=1)
else:
    most_recent_file = os.path.join(TARGET_DIR, 'fallback_file.ipynb')

today_file = os.path.join(TARGET_DIR, f"{today_str}.ipynb")

def extract_tasks(file_path):
    tasks = []
    try:
        with open(file_path, 'r') as file:
            notebook = json.load(file)
            for cell in notebook.get('cells', []):
                if cell.get('cell_type') == 'markdown':
                    for line in cell.get('source', []):
                        if '- [ ]' in line:
                            tasks.append(line.strip())
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Warning: Could not read tasks from file {file_path}. Error: {e}")
    return tasks

def create_notebook(file_path, date, tasks):
    tasks_str = "\n".join(tasks) if tasks else "*No tasks available from yesterday.*"
    new_notebook = {
        "cells": [
            {"cell_type": "markdown", "metadata": {}, "source": [f"# {date}\n"]},
            {"cell_type": "markdown", "metadata": {}, "source": [f"## Todo\n\n{tasks_str}\n"]},
        ],
        "metadata": {},
        "nbformat": 4,
        "nbformat_minor": 4
    }
    
    with open(file_path, 'w') as file:
        json.dump(new_notebook, file, indent=4)

if os.path.isfile(today_file):
    print("Today's file already exists, opening...")
else:
    markdown_date = today.strftime("%B %d, %Y")
    yesterday_tasks = extract_tasks(most_recent_file)
    create_notebook(today_file, markdown_date, yesterday_tasks)
