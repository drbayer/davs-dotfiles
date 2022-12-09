#!/usr/bin/env python3

from setuptools import setup, find_packages

setup(
    name='python_package',
    version='0.0.1',
    py_modules=find_packages(),
    include_package_data=True,
    install_requires=[
        'Click',
    ],
    entry_points={
        'console_scripts': [
            'python_package = python_package.scripts.python_package:python_package',
        ],
    },
)
