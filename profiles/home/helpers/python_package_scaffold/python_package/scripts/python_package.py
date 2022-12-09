#!/usr/bin/env python3

import click
import os
from python_package.scaffold import Scaffold

CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])

@click.group(context_settings=CONTEXT_SETTINGS)
def python_package():
    pass

@python_package.command(context_settings=CONTEXT_SETTINGS)
@click.option('-p', '--path', default=os.getcwd(),
        help='Path where the package should be created.')
@click.argument('name')
def new(path, name):
    """ Create a new python package called NAME """
    scaffold = Scaffold(name, path)
    confirm = click.confirm("Create %s in %s" % 
            ( scaffold.name, scaffold.path ),
            show_default=True, default=True)
    if confirm:
        if scaffold.exists:
            click.secho(f"{scaffold.path} already exists. Aborting scaffold creation.",
                    err=True, color=True, fg="bright_red")
            return

        try:
            scaffold.create_dirs()
            scaffold.create_files()
            click.echo("Created %s in %s" % 
                    (scaffold.name, scaffold.path))
        except Exception as e:
            e.__suppress_context__ = True
            click.secho("Error creating scaffolding", err=True, color=True, fg="bright_red")
            click.secho(str(e), err=True, color=True, fg="bright_red")

