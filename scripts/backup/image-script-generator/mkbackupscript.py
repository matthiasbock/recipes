#!/usr/bin/env python3

import os
import shutil
import sys
import click
import subprocess
import hashlib
from pathlib import Path
from jinja2 import Template
from typing import List, Dict


def get_free_space(mount_point: str) -> int:
    """
    Get the available free space on a given mount point.

    Args:
        mount_point: Path to the mount point

    Returns:
        Number of available bytes
    """
    statvfs = os.statvfs(mount_point)
    return statvfs.f_frsize * statvfs.f_bavail


def generate_random_key(key_file: str) -> None:
    """
    Generate a random 256-bit key using openssl.

    Args:
        key_file: Path where the key file will be saved
    """
    subprocess.run(["openssl", "rand", "-out", key_file, "-base64", "32"], check=True)  # Generate a 32-byte (256-bit) random key


def create_image(image_path: str, size_bytes: int) -> None:
    """
    Create a random-filled image file of specified size.

    Args:
        image_path: Path where the image file will be created
        size_bytes: Size of the image in bytes
    """
    block_size = 1024 * 1024  # 1MB
    with open(image_path, "wb") as f:
        for _ in range(size_bytes // block_size):
            f.write(os.urandom(block_size))
        f.write(os.urandom(size_bytes % block_size))


@click.command()
@click.argument('source_folder', type=click.Path(exists=True, file_okay=False))
@click.argument('image_prefix', type=str)
@click.argument('dvd_size', type=int)  # DVD size in GB
@click.option('--script_prefix', default='backup_dvd', help='Prefix for generated bash scripts')
@click.option('--margin', default=100, help='Minimum free space margin in MB')
def backup(source_folder: str, image_prefix: str, dvd_size: int, script_prefix: str, margin: int) -> None:
    """
    Generate backup scripts for splitting a folder across multiple DVDs.

    Args:
        source_folder: Path to the folder to backup
        image_prefix: Prefix for generated image files
        dvd_size: Size of each DVD in GB
        script_prefix: Prefix for generated bash scripts
        margin: Minimum free space margin in MB
    """
    dvd_size_bytes = dvd_size * 1024 * 1024 * 1024
    margin_bytes = margin * 1024 * 1024

    dvd_index = 1
    dvd_usage = 0
    current_files: List[Dict[str, str]] = []

    with open('scripts/backup/image-script-generator/template.sh.j2') as f:
        template = Template(f.read())

    script_filepath = f"{script_prefix}-{dvd_index}.sh"
    script = open(script_filepath, 'w')

    for root, _, files in os.walk(source_folder):
        for file in files:
            source_path = os.path.join(root, file)
            relative_path = os.path.relpath(source_path, source_folder)
            file_size = os.path.getsize(source_path)

            if dvd_usage + file_size + margin_bytes > dvd_size_bytes:
                # Render template for current DVD
                script.write(template.render(
                    image_path=f"{image_prefix}-{dvd_index}.img",
                    key_file=f"{image_prefix}-{dvd_index}.key",
                    dvd_size_mb=dvd_size*1024,
                    dvd_index=dvd_index,
                    source_folder_basename=os.path.basename(source_folder),
                    files=current_files
                ))
                script.close()

                # Start new DVD
                dvd_index += 1
                dvd_usage = 0
                current_files = []
                script_filepath = f"{script_prefix}-{dvd_index}.sh"
                script = open(script_filepath, 'w')

            destination_path = os.path.join(f"/mnt/dvd{dvd_index}", os.path.basename(source_folder), relative_path)
            current_files.append({
                'source_path': source_path,
                'destination_path': destination_path
            })
            dvd_usage += file_size

    # Render template for final DVD
    script.write(template.render(
        image_path=f"{image_prefix}-{dvd_index}.img",
        key_file=f"{image_prefix}-{dvd_index}.key",
        dvd_size_mb=dvd_size*1024,
        dvd_index=dvd_index,
        source_folder_basename=os.path.basename(source_folder),
        files=current_files
    ))
    script.close()


if __name__ == '__main__':
    backup()

