# from distutils.core import setup, find_packages
from __future__ import print_function

import sys
from os import path

from setuptools import setup, find_packages

if "sdist" in sys.argv or "bdist_wheel" in sys.argv:
    skip_pre_and_post = True
else:
    skip_pre_and_post = False

this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, "README.md")) as f:
    long_description = f.read()


def _pre_install():
    """Pre-installation tasks:"""
    # If we don't have a FS directory structure, quit

    print("-" * 80)
    print("Checking for a Field System installation...")
    say_goodbye = False
    for p in [
        "/usr2/fs",
        "/usr2/st",
        "/usr2/control",
    ]:
        if not path.exists(p):
            print("Could not find the directiory {}".format(p))
            say_goodbye = True
        else:
            print("Found {}".format(p))
    if say_goodbye:
        print("Can't find an installed Field System distribution. Quitting")
        sys.exit()
    else:
        print("Field System directories found.")
    print("-" * 80)


def _post_install():
    """Post-installation tasks:"""
    pass


if not skip_pre_and_post:
    _pre_install()

setup(
    name="fesh2",
    python_requires=">=3.5.3",
    version="2.3.0",
    url="https://github.com/nvi-inc/fs",
    license="GPL v3",
    author="Jim Lovell",
    author_email="jejlovell@gmail.com",
    description="Geodetic VLBI schedule management and processing",
    long_description=long_description,
    #    long_description_content_type="text/markdown",
    packages=find_packages(),
    include_package_data=True,
    entry_points={
        "console_scripts": [
            "fesh2=fesh2.__main__:main",
        ]
    },
)

if not skip_pre_and_post:
    _post_install()
