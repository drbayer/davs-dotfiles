#!/usr/bin/env python3

from sys import version_info, exit


if version_info < (3,9):
    exit("jira_todoist: Python 3.9 or greater required")


from jira import JIRA
from todoist_api_python.api import TodoistAPI
from enum import Enum
from configparser import ConfigParser
from datetime import date

import os
import re


class TodoistPriority(Enum):
    p1 = 4
    p2 = 3
    p3 = 2
    p4 = 1


class Config:

    def __init__(self, configfile=os.path.join(os.path.expanduser(os.getenv('DOTFILES_BASEDIR')), 'safety-zone', 'safety-zone_values.ini'),
                 section=None):
        cfg = ConfigParser()
        with open(configfile, 'r') as f:
            cfg.read_file(f)
        items = cfg.items(section)
        for item in items:
            setattr(self, item[0], item[1])
            if 'token_file' in item[0] or 'key_file' in item[0]:
                setattr(self, item[0].removesuffix('_file'), self._get_token(item[1]))

    def _get_token(self, tokenfile):
        with open(os.path.expanduser(tokenfile), 'r') as f:
            token = f.read().splitlines()[0]
        return token


class Jira:

    cert = '/opt/homebrew/etc/ca-certificates/cert.pem'

    def __init__(self):
        self.config = Config(section='jira')
        jira_opts = {
            "server": self.config.jira_base_url,
            "verify": self.cert
        }
        self.jira = JIRA(options=jira_opts, basic_auth=(self.config.jira_user, self.config.jira_token))

    def get_issues(self, search_string='assignee=currentUser() AND resolution=Unresolved'):
        return self.jira.search_issues(search_string)


class Todoist:

    def __init__(self):
        self.config = Config(section='todoist')
        self.todoist = TodoistAPI(self.config.todoist_key)
        self._set_project_id()

    def _set_project_id(self):
        self.project_id = [p.id for p in self.todoist.get_projects() if p.name == self.config.todoist_project][0]

    def get_tasks(self):
        filter = f'#{self.config.todoist_project} & @{self.config.todoist_label}'
        return self.todoist.get_tasks(filter=filter)

    def add_task(self, jira_issue):
        todoist_content = f'[{jira_issue.key}]({jira_issue.permalink()}) {jira_issue.fields.summary}'
        duedate = jira_issue.fields.duedate if jira_issue.fields.duedate else date.today().strftime('%Y-%m-%d')
        print(f'Adding Todoist task: {todoist_content}')
        self.todoist.add_task(
            project_id=self.project_id,
            content=todoist_content,
            priority=TodoistPriority.p1.value,
            due_date=duedate,
            labels=[self.config.todoist_label]
        )

    def close_task(self, taskid):
        self.todoist.close_task(task_id=taskid)


def main():
    jira = Jira()
    todoist = Todoist()

    jira_issues = jira.get_issues()
    todoist_tasks = todoist.get_tasks()

    for issue in jira_issues:
        found_tasks = [t for t in todoist_tasks if issue.key in t.content]
        if len(found_tasks) == 0:
            todoist.add_task(issue)
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
        todoist.close_task(task.id)


if __name__ == "__main__":
    main()
