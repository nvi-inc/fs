# from distutils.core import setup, find_packages
from __future__ import print_function

import sys
from os import path, remove
from shutil import copy

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

    print("-"*80)
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
    print("-"*80)


def _post_install():
    """After installation, put the template config file in /usr2/fs/st.default/control
    and tell the user to put a copy in /usr2/control. Warn if there's one there already."""
    config_file_name = "fesh2.config"
    template_control_file_dir = "/usr2/fs/st.default/control"
    station_config_dir = "/usr2/control"
    template_config_file = path.join(this_directory, "fesh2", config_file_name)
    # <blah>/fesh2/fesh2.config
    target_template_config_file = path.join(
        template_control_file_dir,
        config_file_name,
    ) # /usr2/fs/st.default/control/fesh2.config
    target_station_config_file = path.join(station_config_dir, config_file_name) # /usr2/control/fesh2.config
    # Do we have permission to write to the template control file directory
    #    if path.exists template_control_file_dir = "/usr2/fs/st.default/control"
    print("-"*80)
    try:
        if path.exists(target_template_config_file):
            remove(target_template_config_file)
        print(
            "Placing a copy of the template config file {} in {}".format(
                config_file_name,
                template_control_file_dir,
            )
        )
        copy(
            template_config_file,
            target_template_config_file,
        )
    except:
        print("- WARNING " * 8)
        print(
            "Could not put the template config file into the Field System template\n "
            "control file directory (i.e. tried copying {} to\n {}. Permission issue? Try doing "
            "this by hand.".format(
                template_config_file,
                target_template_config_file,
            )
        )
        print("- WARNING " * 8)
    print("-"*80)

    copy_cfg_to_control = False
    if not path.exists(target_station_config_file):
        print(
            "Placing a copy of the template configration file {} in {}.".format(
                config_file_name,
                station_config_dir,
            )
        )
        print("It will need editing for your site.")
        copy_cfg_to_control = True
    else:
        print(
            "A version of the config file {} already exists in {}. ".format(
                config_file_name,
                station_config_dir,
            )
        )
        print(
            "Compare it with the template in {} and make any changes if necessary.".format(
                template_control_file_dir
            )
        )
    if copy_cfg_to_control:
        try:
            copy(
                template_config_file,
                target_station_config_file,
            )
        except:
                print("- WARNING " * 8)
                print(
                "Could not copy the template config file into the Field System\n "
                "control file directory (i.e. tried copying {} to {}.\nPermission issue?) Try "
                "doing this by hand.".format(
                    template_config_file,
                    target_station_config_file,
                ))
                print("- WARNING " * 8)

    print("-"*80)
    print("\n\n")


if not skip_pre_and_post:
    _pre_install()

setup(
    name="fesh2",
    python_requires='>=3.5.3',
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
