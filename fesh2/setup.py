# from distutils.core import setup, find_packages
from __future__ import print_function
from setuptools import setup, find_packages
from os import path, remove
from shutil import copy2
import sys

if "sdist" in sys.argv or "bdist_wheel" in sys.argv:
    skip_pre_and_post = True
else:
    skip_pre_and_post = False

this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md')) as f:
    long_description = f.read()
# package dependencies are diffierent in python versions 2 and 3
if sys.version_info.major == 2:
    install_requires = [
        "pexpect >= 4.7.0",
        "pycurl >=7.43.0.2",
        "configparser >= 4.0.0"
    ]
else:
    install_requires = [
        "pexpect >= 4.7.0",
        "pycurl >=7.43.0.2]"
    ]


def _pre_install():
    """Pre-installation tasks:
        """
    # If we don't have a FS directory structure, quit

    print("Checking for a FS installation...")
    say_goodbye = False
    for p in ["/usr2/fs", "/usr2/st", "/usr2/control"]:
        if not path.exists(p):
            print("Could not find the directiory {}".format(p))
            say_goodbye = True
        else:
            print("Found {}".format(p))
    if say_goodbye:
        print("Can't find an installed Field System distribution. Quitting")
        sys.exit()


def _post_install():
    """After installation, put the template config file in /usr2/fs/st.default/control
    and tell the user to put a copy in /usr2/control. Warn if there's one there already."""
    config_file_name = "fesh2.config"
    template_control_file_dir = "/usr2/fs/st.default/control"
    station_config_dir = "/usr2/control"
    template_config_file = path.join(this_directory, "fesh2", config_file_name)
    target_template_config_file = path.join(template_control_file_dir, config_file_name)
    target_station_config_file = path.join(station_config_dir, config_file_name)
    if path.exists(target_template_config_file):
        remove(target_template_config_file)
    print("Placing a copy of the template config file {} in {}".format(config_file_name, template_control_file_dir))
    copy2(template_config_file, target_template_config_file)

    print("\n#############\n")
    copy_cfg_to_control = False
    if not path.exists(target_station_config_file):
        print("Placing a copy of the template configration file {} in {}.".format(config_file_name,
                                                                                  template_control_file_dir))
        print("It will need editing for your site.")
        copy_cfg_to_control = True
    else:
        print("A version of the config file {} already exists in {}. ".format(config_file_name, station_config_dir))
        print("Compare it with the template in {} and make any changes if necessary.".format(template_control_file_dir))
    if copy_cfg_to_control:
        copy2(template_config_file, target_station_config_file)
    print("\n#############\n\n")

if not skip_pre_and_post:
    _pre_install()

setup(
    name='fesh2',
    version='2.0rc5',
    url='https://github.com/nvi-inc/fs',
    license='GPL v3',
    author='Jim Lovell',
    author_email='jejlovell@gmail.com',
    description='Geodetic VLBI schedule management and processing',
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=find_packages(),
    install_requires=install_requires,
    include_package_data=True,
    entry_points={
        "console_scripts": [
            "fesh2=fesh2.__main__:main",
        ]
    },
)

if not skip_pre_and_post:
    _post_install()
