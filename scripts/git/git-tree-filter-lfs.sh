#!/bin/bash
#
# Migrates a git repository to LFS
# rewriting its history,
# tracking text files via git and binary files via LFS
#
# Usage:
# cd your-git-repository/
# ./<this-script.sh>
#

if [ ! -e .git ]; then
  echo "Not a git repository"
  exit 1
fi

# File extensions to track via git (case-insensitive)
TEXT="txt rst md log"
STRUCTURED="csv tsv xml xsl xslt xsd svg htm html css json scad"
CODE="c cpp cxx h hpp hxx sh py pl js sql"

export EXT_GIT="$TEXT $STRUCTURED $CODE"

# File extensions to track via LFS (case-insensitive)
EXECUTABLES="exe dll bin elf"
ARCHIVES="zip tar gz gzip bz2 bzip2 ar rar 7z 7za pack"
DATABASES="db db3 db4 sqlite sqlite3 hdf hdf5"
IMAGES="img iso"
LIBREOFFICE="odt ods odp"
MSOFFICE="doc docx xls xlsx ppt pptx potx"
FREECAD="fcstd fcstd1"
AUTOCAD="dxf"
DOCUMENTS="$LIBREOFFICE $MSOFFICE pdf ppm ps eps $FREECAD $AUTOCAD"
PICTURES="jpg jpeg png dng bmp tif tiff tga webp xcf psd"
AUDIO="wav off mp3 m4a au"
VIDEO="avi webm m2ts mp4 mkv"

export EXT_LFS="$EXECUTABLES $ARCHIVES $DATABASES $IMAGES $DOCUMENTS $PICTURES $AUDIO $VIDEO"

# # Helper function which makes sure a file is tracked the desired way, via git or LFS
# git_readd() {
#   git rm -f --cached -q "$1"
#   git add -f "$1"
# }

# # When this script is called from function process_working_tree below, execute the above function
# if [ "$1" == "git_readd" ]; then
#   git_readd "$2"
#   exit 0
# fi

# # Processes all files in the working tree
# process_working_tree() {
#   # Make sure, git-lfs is installed in the current repository
#   git lfs install --local --force

#   # Update files in the working tree to match the version in the index
#   git checkout -- . || \
#   { echo "git checkout failed" >&2 && exit 1; }

#   # Download all LFS objects referenced by any reachable commit in the repository
#   git lfs fetch --all || \
#   { echo "git lfs fetch failed" >&2 && exit 1; }

#   [[ "$EXT_GIT" != "" ]] && \
#   [[ "$EXT_LFS" != "" ]] || \
#   { echo "No files to process" >&2 && exit 1; }

#   # Process files to be tracked by Git
#   for EXT in $EXT_GIT; do
#     # Make sure, matching files are checked out
#     find -L . -type f -iname "*.$EXT" \
#       -print \
#       -exec bash -c 'git lfs checkout "$FILENAME" || git checkout "$FILENAME" || exit 2' _ {} \; || \
#     { echo "Failed to check out files" >&2 && exit 2; }

#     # Remove file pattern from LFS tracking
#     git lfs untrack "*.$EXT"
#     git lfs untrack "*.$(echo "$EXT" | tr [:lower:] [:upper:])"

#     # Make sure, matching files are added to git
#     find -L . -type f -iname "*.$EXT" \
#       -exec "$0" git_readd "$FILENAME" \; || \
#     { echo "Failed to add files to git" >&2 && exit 3; }
#   done

#   git rm -f --cached .gitattributes || true

#   # Process files to be tracked by LFS
#   for EXT in $EXT_LFS; do
#     # Add file pattern to LFS tracking
#     git lfs track "*.$EXT" 1>/dev/null
#     git lfs track "*.$(echo "$EXT" | tr [:lower:] [:upper:])" 1>/dev/null

#     # Make sure, matching files are added to LFS
#     find -L . -type f -iname "*.$EXT" \
#       -exec "$0" git_readd "$FILENAME" \; || \
#     { echo "Failed to add files to LFS" >&2 && exit 3; }
#   done

#   git add .gitattributes

#   # FIXME: Apparently, a file was lost in the assets repo.
#   # It's better to just add everything, in order not to loose anything.
#   git add -A
# }

# # When this script is called from git-filter-branch, execute the above function
# if [ "$1" == "process_working_tree" ]; then
#   process_working_tree
#   exit
# fi

# Temporarily disable compression during filtering, for performance reasons
git config core.compression 0

# Rewrite history, one commit at a time
# git filter-branch \
#   --prune-empty \
#   -f \
#   --tree-filter 'bash -c "$0" process_working_tree' \
#   --tag-name-filter cat \
#   -- --all

echo "Exporting files to git"

# Build a string of arguments for git lfs migrate export
ARGS=""
for EXT in $EXT_GIT; do
  EXT_UPPER=$(echo "$EXT" | tr [:lower:] [:upper:])
  ARGS+="--include=*.${EXT} --include=*.${EXT_UPPER} "
done

# Update history for all file extensions in one command
git lfs migrate export \
  --everything \
  ${ARGS} || \
{ echo "Export failed with exit code $?" >&2 && exit 1; }


echo "Importing files to LFS"

# Build a string of arguments for git lfs migrate import
ARGS=""
for EXT in $EXT_LFS; do
  EXT_UPPER=$(echo "$EXT" | tr [:lower:] [:upper:])
  ARGS+="--include=*.${EXT} --include=*.${EXT_UPPER} "
done

# Update history for all file extensions in one command
git lfs migrate import \
  --everything \
  ${ARGS} || \
{ echo "Import failed with exit code $?" >&2 && exit 1; }

# EXITCODE=$?

# Deprecated version:
  # --tree-filter '
  #   git lfs install;
  #   git lfs fetch --all;
  #   git checkout -- . ;

  #   for EXT in $EXT_GIT; do
  #     find -L . -type f -iname "*.$EXT" \
  #     -print \
  #     -exec git lfs checkout "{}" \; ;
  #     git lfs untrack "*.$EXT";
  #     git lfs untrack "*.$(echo $EXT  | tr [:lower:] [:upper:])";
  #     for FILENAME in $(find -L . -type f -iname "*.$EXT"); do \
  #       git rm -f --cached -q "$FILENAME"; \
  #       git add -f "$FILENAME"; \
  #     done;
  #   done;
  #   git rm -f --cached .gitattributes || true;
  #   [[ "$EXT_LFS" != "" ]] || exit 1;
  #   for EXT in $EXT_LFS; do
  #     git lfs track "*.$EXT" 1>/dev/null || exit 2;
  #     git lfs track "*.$(echo $EXT  | tr [:lower:] [:upper:])" 1>/dev/null || exit 2;
  #     find -L . -type f -iname "*.$EXT" -exec bash -c " \
  #       echo "Adding to LFS: $FILENAME"; \
  #       git lfs checkout "$FILENAME" || git checkout "$FILENAME" || exit 3; \
  #       git rm -f --cached -q "$FILENAME"; \
  #       git add -f "$FILENAME"; \
  #     done;
  #   done;
  #   git add .gitattributes;
  #   git add -A;
  # ' \

# Check if git filter-branch succeeded
# if [ $EXITCODE -ne 0 ]; then
#   echo "Error: git filter-branch failed with exit code $EXITCODE"
#   exit $EXITCODE
# fi

# Remove old refs
# echo "Removing old refs..."
# git for-each-ref --format="%(refname)" refs/original/ | \
# xargs -n 1 git update-ref -d || \
# { echo "Error: Failed to remove old refs, exit code $?" >&2; exit 8; }

# Clean up
git reflog expire --expire=now --expire-unreachable=now --all && \
git gc --aggressive --prune=now && \
git prune || { echo "Error: Cleanup failed with exit code $?" >&2; exit 9; }

# De-duplicate files
echo "De-duplicating files..."
git lfs dedup | tail -n3 #1>/dev/null

# Re-enable compression
echo "Re-enabling compression..."
git config core.compression 9
git repack -F || \
{ echo "Error: git repack failed with exit code $?" >&2; exit 10; }

# Print summary
echo "Files stored in LFS:"
git lfs ls-files -a && \
echo "Done."


#git clean -fx;
#git lfs prune --verify-remote -v;

