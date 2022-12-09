#!/usr/bin/env python3

import os


class Scaffold:

    def __init__(self, name, path):
        self.name = name
        # handle both relative and ~/ paths
        self.path = os.path.realpath(os.path.expanduser(path))
        self.path = os.path.join(self.path, name)
        self.exists = os.path.exists(self.path)

    def create_dirs(self):
        os.makedirs(os.path.join(self.path, "src", "scripts"))

    def create_files(self):
        # base dir files
        open(os.path.join(self.path, "README.md"), "x")
        with open(os.path.join(self.path, "setup.py"), "w") as setupfile:
            setupfile.write(self.get_setup())

        # src dir files
        open(os.path.join(self.path, "src", "__init__.py"), "x")

        # scripts dir files
        open(os.path.join(self.path, "src", "scripts", "__init__.py"), "x")
        open(os.path.join(self.path, "src", "scripts",
             ".".join([self.name, "py"])), "x")

    def get_setup(self):
        name = self.name
        content = (
            "#!/usr/bin/env python3\n",
            "from setuptools import setup, find_packages\n",
            "setup(",
            f"    name='{name}',",
            "    version='0.0.1',",
            "    py_modules=find_packages(),",
            "    include_package_data=True,",
            "    install_requires=[",
            "    ],",
            "    entry_points={",
            "        'console_scripts': [",
            f"            '{name} = src.scripts.{name}:{name}',",
            "        ],",
            "    },",
            ")"
            )
        return "\n".join(content)
