import argparse
import os
import subprocess
import sys
from pathlib import Path
from Utils.param_manager import ParamManager


def main():
    parser = argparse.ArgumentParser(description="Configure Derivia build")
    parser.add_argument("--http-proxy", default="http://127.0.0.1:7890")
    parser.add_argument("--https-proxy", default="http://127.0.0.1:7890")
    # parser.add_argument("--msvc-version", default="1929")
    parser.add_argument("--build-type", default="RelWithDebInfo")
    parser.add_argument("--persist-file", default=None)
    parser.add_argument("--load-params", action="store_true")
    parser.add_argument("--save-params", action="store_true")
    args = parser.parse_args()

    param_manager = None
    if args.persist_file:
        param_manager = ParamManager(Path(args.persist_file))

        if args.load_params:
            loaded = param_manager.load()
            for k, v in loaded.items():
                setattr(args, k, v)

    os.environ["http_proxy"] = args.http_proxy
    os.environ["https_proxy"] = args.https_proxy

    if args.save_params and param_manager:
        param_manager.save(vars(args))

    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    build_dir = project_root / "build"
    build_dir.mkdir(exist_ok=True)

    cmake_cmd = [
        "cmake",
        "-S", str(project_root),
        "-B", str(build_dir),
        "-G", "Ninja",
        f"-DCMAKE_BUILD_TYPE={args.build_type}",
        f"-DCUSTOM_HTTP_PROXY={args.http_proxy}",
        f"-DCUSTOM_HTTPS_PROXY={args.https_proxy}",
        "-DCMAKE_TOOLCHAIN_FILE=" +
        str(project_root / "CMake/Toolchains/Ninja_MSVC.cmake"),
        '-DCMAKE_CXX_FLAGS=/MP',
        '-DBUILD_TESTING=OFF',
        '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
    ]

    if sys.platform == "win32":
        vcvars_path = build_dir / "CMakeFiles" / "vcvars64_wrapper.bat"
        if vcvars_path.exists():
            cmake_cmd[0] = f'''call "{vcvars_path}" && cmake'''


    print("Running CMake command:")
    cmd = " ".join(map(str, cmake_cmd))
    print(cmd)
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        sys.exit(result.returncode)


if __name__ == "__main__":
    main()
