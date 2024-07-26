{ writers }:
writers.writePython3Bin "find-orphaned" { } ''
  import sys
  import os
  if len(sys.argv) != 2:
      print("Please give a singular argument containing the folder to prune")
      exit(1)
  mountpoint = sys.argv[1]
  if !os.path.exists(mountpoint)):
      print("Argument has to exist")
      exit(1)
  with open("/proc/mounts", "r") as f:
      mounts = [line.split() for line in f.readlines()]
  toplevel =
  current = [mountpoint]
  print(os.listdir(mountpoint))
''
