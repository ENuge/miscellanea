#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

bool is_valid_dir(char *dir) {
  // Use stat to make sure the given directory actually exists
  struct stat statbuf;
  int return_code = stat(dir, &statbuf);
  return (bool)return_code;
}

char *construct_tab_start(int num_tabs) {
  // Used to get a little indentation to make the output easier to read
  if (num_tabs == 0) {
    return "";
  }
  char *tab_string = malloc(num_tabs * sizeof(char));
  for (int i = 0; i < num_tabs; i++) {
    tab_string[i] = '\t';
  }
  return tab_string;
}

void output_children(int tab_level) {
  // This function assumes the caller has already chdir'ed it into the right
  // context
  char *dir = NULL;
  dir = getcwd(dir, 0);
  DIR *dp = opendir(dir);
  if (dp == NULL) {
    fprintf(stderr,
            "Giving up on trying to open %s , but will bravely plow onwards\n",
            dir);
    return;
  }
  assert(dp != NULL);

  struct dirent *dir_entry;
  while ((dir_entry = readdir(dp)) != NULL) {
    // Skip the directory itself and its parent because otherwise we'll
    // infinitely recurse
    if (strcmp(dir_entry->d_name, ".") == 0 ||
        strcmp(dir_entry->d_name, "..") == 0) {
      continue;
    }

    char *tab_start = construct_tab_start(tab_level);
    printf("%s%s\n", tab_start, dir_entry->d_name);
    if (dir_entry->d_type == DT_DIR) {
      // Before recursing, update the working directory. And then after
      // recursing, unwind it back to the original!
      int rc = chdir(dir_entry->d_name);
      if (rc != 0) {
        fprintf(stderr, "Couldn't chdir for some reason, return code: %d\n",
                rc);
      }

      output_children(tab_level + 1);

      rc = chdir(dir);
      if (rc != 0) {
        fprintf(stderr,
                "Couldn't chdir back to starting_dir for some reason, return "
                "code: %d\n",
                rc);
      }
    }
  }
}

int main(int argc, char *argv[]) {
  // Recursively prints all child files of a given directory.
  bool are_args_valid = true;
  char *starting_dir = NULL;

  if (argc > 2) {
    are_args_valid = false;
  }
  if (argc == 2) {
    char *maybe_starting_dir = argv[1];
    if (is_valid_dir(maybe_starting_dir)) {
      starting_dir = maybe_starting_dir;
    } else {
      are_args_valid = false;
    }
  } else {
    starting_dir = getcwd(starting_dir, 0);
  }

  if (!are_args_valid) {
    fprintf(stderr, "Usage: rfind [starting_directory], where "
                    "starting_directory is the optional (relative or absolute) "
                    "path to a starting directory.");
    exit(1);
  }

  int rc = chdir(starting_dir);
  if (rc != 0) {
    fprintf(stderr, "Couldn't chdir for some reason, return code: %d\n", rc);
  }
  output_children(0);

  return 0;
}