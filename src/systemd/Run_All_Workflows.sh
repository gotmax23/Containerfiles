gh workflow list | awk '{print $8}' | xargs -n 1 gh workflow run
