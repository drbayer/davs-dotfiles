#!/usr/bin/env python3

import sys


if sys.version_info < (3,9):
    sys.exit("jira_todoist: Python 3.9 or greater required")


from getpass import getuser
from jira import JIRA
from todoist_api_python.api import TodoistAPI
from enum import Enum

import os
import re


class TodoistPriority(Enum):
    p1 = 4
    p2 = 3
    p3 = 2
    p4 = 1


def add_todoist_task(jira_issue):
    todoist_content = f'[{jira_issue.key}]({jira_issue.permalink()}) {jira_issue.fields.summary}'
    print(f'Adding Todoist task: {todoist_content}')
    todoist.add_task(
        project_id=todoist_project_id,
        content=todoist_content,
        priority=TodoistPriority.p1.value,
        due_string='today',
        labels=[todoist_label]
    )


jira_base_url = 'https://klover.attlassian.net/'
jira_user = 'dbayer@attaindata.io'
jira_token_file = os.path.join(os.path.expanduser('~'), '.ssh', 'jira_token')
jira_search_string = 'assignee=currentUser() AND resolution = Unresolved'

with open(jira_token_file, 'r') as f:
    jira_token = f.read().splitlines()[0]

jira = JIRA(jira_base_url, basic_auth=(jira_user, jira_token))
jira_issues = jira.search_issues(jira_search_string)

todoist_key_file = os.path.join(os.path.expanduser('~'), '.ssh', 'todoist')
todoist_project = 'Attain'
todoist_project_id = 0
todoist_label = 'jira'
todoist_search_string = f'#{todoist_project} & @jira'

with open(todoist_key_file, 'r') as f:
    todoist_api_key = f.read().splitlines()[0]

todoist = TodoistAPI(todoist_api_key)
todoist_project_id = [p.id for p in todoist.get_projects() if p.name == todoist_project][0]

if todoist_project_id == 0:
    exit("Unable to determined Todoist project ID or label ID. Aborting script.")

todoist_tasks = todoist.get_tasks(filter=todoist_search_string)

for issue in jira_issues:
    found_tasks = [t for t in todoist_tasks if issue.key in t.content]
    if len(found_tasks) == 0:
        add_todoist_task(issue)
    elif len(found_tasks) == 1:
        print(f'Found existing task: {found_tasks[0].content}')
        jira_issues = [i for i in jira_issues if i.key != issue.key]
        todoist_tasks.remove(found_tasks[0])
    elif len(found_tasks) > 1:
        msg = f'Multiple Todoist tasks found for {issue.key}:\n'
        for task in found_tasks:
            msg += f'  {task.content}'
        print(msg)

for task in todoist_tasks:
    print(f'Closing task {task.content}')
    todoist.close_task(task_id=task.id)
