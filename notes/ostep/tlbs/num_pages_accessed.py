import re
import sys
import subprocess

def main(debug_mode):
  """Run ./tlb num_pages num_trials with num_pages doubling from 1 to 1012,
  for 10 trials at each round. For now will just print out the results.
  """
  num_pages = 1
  max_num_pages = 10000
  # Hackish printing: I'm printing out headers for a csv, and then
  # pasting all of this into an Excel spreadsheet for graphing
  if not debug_mode:
    print("Num Pages,Time Diff (microseconds)")
  while (num_pages <= max_num_pages):
    # subprocess.check_output(["bash", "./tlb"])
    result_string = subprocess.check_output(["./tlb", str(num_pages), "10"]).decode('unicode_escape')
    regex = r"Average time diff is: (\d+.\d+) microseconds"
    match = re.search(regex, result_string)
    if match:
      time_diff_micros = match.group(1)
      if debug_mode:
        print(f"num_pages: {num_pages}, time diff (microseconds): {time_diff_micros}")
      else:
        print(f"{num_pages},{time_diff_micros}")
    else:
      print(f"Did not find a match! The result_string was {result_string}")

    num_pages *= 2

if __name__ == "__main__":
  debug_mode = len(sys.argv) > 1 and sys.argv[1] == 'debug'
  main(debug_mode)