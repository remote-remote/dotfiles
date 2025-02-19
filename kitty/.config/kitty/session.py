import argparse
import json
import os
import re
import subprocess
from datetime import datetime
from typing import List

from kitty.boss import Boss

parser = argparse.ArgumentParser(description="meow")
parser.add_argument("command", nargs="?", default="load")
parser.add_argument(
    "--dir",
    dest="dirs",
    action="append",
    default=[],
    help="directories to find projects",
)


def new_main(args, opts):
    try:
        url = input("🐈 new (name or github url): ")
        return url
    except KeyboardInterrupt:
        return ""


def new_handler(args: List[str], answer: str, target_window_id: int, boss: Boss):
    opts = parser.parse_args(args[1:])

    # This is the dir we clone repos into, for me it's not a big deal if they get cloned to the
    # first dir. But some people might want to pick which dir to clone to? How could that be
    # supported?
    projects_root = opts.dirs[0]

    if not answer:
        return
    elif "/" in answer:
        # Note: This is an attempt to see if the answer is a git url or not, e.g.
        #   - git@github.com:taylorzr/kitty-meow.git
        #   - https://github.com/taylorzr/kitty-meow.git
        github_url = answer
        dir = re.split("[/.]", github_url)[2]
        print(f"cloning into {dir}...")
        path = f"{projects_root}/{dir}"
        subprocess.run(["git", "clone", github_url, path])
    else:
        new_local = answer
        dir = new_local
        path = f"{projects_root}/{dir}"
        os.makedirs(path, exist_ok=True)

    load_project(boss, path, dir)


def load_main(args, opts):
    # FIXME: How to call boss in the main function?
    # data = boss.call_remote_control(None, ("ls",))
    kitty_ls = json.loads(
        subprocess.run(
            ["kitty", "@", "ls"], capture_output=True, text=True
        ).stdout.strip("\n")
    )

    tabs = [tab["title"] for item in kitty_ls for tab in item["tabs"]]
    tabs_and_projects = [tab["title"] for item in kitty_ls for tab in item["tabs"]]
    projects = []

    for dir in opts.dirs:
        if dir.endswith("/"):
            for f in os.scandir(dir):
                if f.is_dir():
                    name = os.path.basename(f.path)
                    pretty_path = f.path.replace(os.path.expanduser("~"), "~", 1)
                    projects.append(pretty_path)
                    if name not in tabs_and_projects:
                        tabs_and_projects.append(pretty_path)
        else:
            name = os.path.basename(dir)
            projects.append(dir)
            if name not in tabs_and_projects:
                tabs_and_projects.append(dir)

    bin_path = os.getenv("BIN_PATH", "")

    args = [
        f"{bin_path}fzf",
        "--multi",
        "--reverse",
        "--prompt=🐈 meow > ",
    ]
    p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    out = p.communicate(input="\n".join(tabs_and_projects).encode())[0]
    output = out.decode().strip()

    # from kittens.tui.loop import debug
    # debug(output)

    if output == "":
        return []

    return output.split("\n")


def load_project(boss, path, dir):
    with open(f"{os.path.expanduser('~')}/.config/kitty/meow/history", "a") as history:
        history.write(f"{dir} {datetime.now().isoformat()}\n")
        history.close()

    kitty_ls = json.loads(boss.call_remote_control(None, ("ls",)))

    for window in kitty_ls:
        for tab in window["tabs"]:
            if tab["title"] == dir:
                boss.call_remote_control(None, ("focus-window", "-m", f"title:^{dir}$"))
                return

    window_id = boss.call_remote_control(
        None,
        (
            "launch",
            "--type",
            "os-window",
            "--tab-title",
            dir,
            "--cwd",
            path,
        ),
    )

    parent_window = boss.window_id_map.get(int(window_id))
    boss.call_remote_control(parent_window, ("set-window-title", dir))


def load_handler(args: List[str], answer: str, target_window_id: int, boss: Boss):
    opts = parser.parse_args(args[1:])

    # This is the dir we clone repos into, for me it's not a big deal if they get cloned to the
    # first dir. But some people might want to pick which dir to clone to? How could that be
    # supported?
    projects_root = opts.dirs[0]

    if not answer:
        return

    for selection in answer:
        # NOTE: selection can be a variety of patterns
        # - meow
        # - ~/.config/kitty/meow/
        # - kitty-meow git@github.com:taylorzr/kitty-meow.git
        # - meow 2023-03-23T20:52:21.841221
        path, *rest = selection.split()
        dir = os.path.basename(path)

        if len(rest) == 1:
            ssh_url = rest[0]
            print(f"cloning into {dir}...")
            path = f"{projects_root}/{dir}"
            subprocess.run(["git", "clone", ssh_url, path])
            # TODO: handle error, like unset sso on ssh key and try this
        elif len(rest) != 0:
            print("something bad happenend :(")

        load_project(boss, path, dir)


def main(args: List[str]) -> str:
    opts = parser.parse_args(args[1:])

    if opts.command == "load":
        return load_main(args, opts)
    elif opts.command == "new":
        return new_main(args, opts)


def handle_result(
    args: List[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    opts = parser.parse_args(args[1:])

    if opts.command == "load":
        return load_handler(args, answer, target_window_id, boss)
    elif opts.command == "new":
        return new_handler(args, answer, target_window_id, boss)
