import json
import os
from datetime import datetime, timedelta

TARGET_DIR =  "/Users/yourname/etc"

# Get today's date
today = datetime.now()
today_str = today.strftime("%m_%d_%y")

most_recent_file_date = today - timedelta(days=1)  # Start with yesterday
found = False

while not found:
    most_recent_file_str = most_recent_file_date.strftime("%m_%d_%y")
    most_recent_file = os.path.join(TARGET_DIR, f"{most_recent_file_str}.ipynb")
    if os.path.exists(most_recent_file):
        found = True  # File found, stop the loop
    else:
        most_recent_file_date -= timedelta(days=1)

if found:
    yesterday_file = most_recent_file  # Use most_recent_file as the source for tasks
else:
    # Fallback to yesterday's logic or an empty list if no recent file is found
    yesterday_file = os.path.join(TARGET_DIR, 'fallback_file.ipynb')

today_file = os.path.join(TARGET_DIR, f"{today_str}.ipynb")

def extract_tasks(file_path):
    tasks = []
    try:
        with open(file_path, 'r') as file:
            notebook = json.load(file)
            for cell in notebook['cells']:
                if cell['cell_type'] == 'markdown':
                    for line in cell['source']:
                        if '- [ ]' in line:
                            tasks.append(line.strip())
            return tasks
    except Exception as e:
        return []

def create_notebook(file_path, date, tasks):
    tasks_str = "\n".join(tasks)
    new_notebook = {
        "cells": [
            {"cell_type": "markdown", "metadata": {}, "source": [f"# {date}"]},
            {"cell_type": "markdown", "metadata": {}, "source": [f"## Todo\n\n{tasks_str}"]},
        ],
        "metadata": {},
        "nbformat": 4,
        "nbformat_minor": 4
    }
    
    with open(file_path, 'w') as file:
        json.dump(new_notebook, file, indent=4)

# Main script
if os.path.isfile(today_file):
    print("Today's file already exists, opening...")
else:
    # Date for first cell
    markdown_date = today.strftime("%B %d, %Y")
    yesterday_tasks = extract_tasks(yesterday_file)
    create_notebook(today_file, markdown_date, yesterday_tasks)

