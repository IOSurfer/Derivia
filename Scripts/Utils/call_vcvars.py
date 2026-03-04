import subprocess
import os

def call_vcvars(vcvars_path):
    """
    Windows only: invoke vcvars64_wrapper.bat
    """
    if not vcvars_path.exists():
        raise FileNotFoundError(f"{vcvars_path} not found.")

    result = subprocess.run(
        f'cmd /c "{vcvars_path}" && set',
        capture_output=True,
        text=True,
        shell=True
    )
    if result.returncode != 0:
        print(result.stderr)
        raise RuntimeError("vcvars64_wrapper.bat execution failed.")
    for line in result.stdout.splitlines():
        if '=' in line:
            key, value = line.split('=', 1)
            os.environ[key] = value