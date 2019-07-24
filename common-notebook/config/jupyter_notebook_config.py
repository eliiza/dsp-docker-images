# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import errno
import stat
from notebook.notebookapp import NotebookWebApplication
from notebook.utils import url_path_join

def fixed__init__(self, jupyter_app, kernel_manager, contents_manager,
                 session_manager, kernel_spec_manager,
                 config_manager, extra_services, log,
                 base_url, default_url, settings_overrides, jinja_env_options):

        settings = self.init_settings(
            jupyter_app, kernel_manager, contents_manager,
            session_manager, kernel_spec_manager, config_manager,
            extra_services, log, base_url,
            default_url, settings_overrides, jinja_env_options)
        handlers = self.init_handlers(settings)
        modified_handlers = []

        for handler in handlers:
            if '@' in handler[0]:
                unescaped_path = handler[0].replace('@', r'%40')
                modified_handlers.append(tuple([handler[0]] + list(handler[1:])))
                modified_handlers.append(tuple([unescaped_path] + list(handler[1:])))
            else:
                modified_handlers.append(handler)

        print("\n".join([str(x) for x in modified_handlers]))

        super(NotebookWebApplication, self).__init__(modified_handlers, **settings)

NotebookWebApplication.__init__ = fixed__init__


c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False

# https://github.com/jupyter/notebook/issues/3130
c.FileContentsManager.delete_to_trash = False

# Generate a self-signed certificate
if 'GEN_CERT' in os.environ:
    dir_name = jupyter_data_dir()
    pem_file = os.path.join(dir_name, 'notebook.pem')
    try:
        os.makedirs(dir_name)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(dir_name):
            pass
        else:
            raise

    # Generate an openssl.cnf file to set the distinguished name
    cnf_file = os.path.join(os.getenv('CONDA_DIR', '/usr/lib'), 'ssl', 'openssl.cnf')
    if not os.path.isfile(cnf_file):
        with open(cnf_file, 'w') as fh:
            fh.write('''\
[req]
distinguished_name = req_distinguished_name
[req_distinguished_name]
''')

    # Generate a certificate if one doesn't exist on disk
    subprocess.check_call(['openssl', 'req', '-new',
                           '-newkey', 'rsa:2048',
                           '-days', '365',
                           '-nodes', '-x509',
                           '-subj', '/C=XX/ST=XX/L=XX/O=generated/CN=generated',
                           '-keyout', pem_file,
                           '-out', pem_file])
    # Restrict access to the file
    os.chmod(pem_file, stat.S_IRUSR | stat.S_IWUSR)
    c.NotebookApp.certfile = pem_file

# Change default umask for all subprocesses of the notebook server if set in
# the environment
if 'NB_UMASK' in os.environ:
    os.umask(int(os.environ['NB_UMASK'], 8))
