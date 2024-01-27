# Project: PIC (Personal Incremental Changes)

## Description
PIC is a bash script for real-time monitoring and version control of directories, inspired by Git functionalities and designed with ASO (Administración de Sistemas Operativos) principles in mind. It uses `inotify` to track modifications within directories, saving each file's versions with a timestamp and providing tools for reviewing change history and reverting to specific states.

## Installation
1. Install `inotify-tools` (if not already installed):
   ```bash
   sudo apt-get install inotify-tools
   ```
2. Clone this repository or download the `pic` script.
3. Grant execution permissions:
   ```bash
   chmod +x pic
   ```
## Usage
The `pic` script functions with several commands, following standard syntax conventions:

- **Initialize Repository:**
  ```
  pic init <directory>
  ```
  Initializes a version control repository within the specified directory.

- **Start Watching Directory:**
  ```
  pic watch
  ```
  Begins monitoring the current directory for any file changes.

- **View Change Log:**
  ```
  pic log
  ```
  Displays the recorded history of changes within the directory.

- **Check Current Status:**
  ```
  pic status
  ```
  Shows the current uncommitted changes in the directory.

- **Create Snapshot:**
  ```
  pic snap [--message <commit-message>]
  ```
  Creates a snapshot of the current state of the directory, optionally with a commit message.

- **Recover Specific Snapshot:**
  ```
  pic goto <snapshot-timestamp>
  ```
  Reverts the directory to the state at the specified snapshot timestamp.

- **Help:**
  ```
  pic help [command]
  ```
  Provides help about a specific command or general usage if no command is specified.
  
## Examples of Use

- **Initializing a Repository:**
  ```bash
  # Initialize a PIC repository in the current directory
  pic init .
  ```

- **Start Monitoring a Directory:**
  ```bash
  # Begin watching the current directory for changes
  pic watch
  ```

- **Creating a Snapshot:**
  ```bash
  # Create a snapshot without a message
  pic snap

  # Create a snapshot with a custom commit message
  pic snap --message "Initial commit"
  ```

- **Viewing the Change Log:**
  ```bash
  # Display the change history of the current directory
  pic log
  ```

- **Checking Current Status:**
  ```bash
  # Show uncommitted changes in the directory
  pic status
  ```

- **Reverting to a Specific Snapshot:**
  ```bash
  # Revert to a state of the directory at a specific timestamp
  pic goto 20230101T15:30:00
  ```

## Contributing
Contributions to enhance PIC are welcome. Please fork the repository, create a feature branch, and submit a pull request for review.

## References
- Git: PIC is inspired by Git's version control mechanisms. For more insights, refer to the [Pro Git book](https://git-scm.com/book/en/v2).
- ASO: This project is a practical application of ASO course concepts, focusing on system administration and scripting.

## Licensing
This project is licensed under the MIT License.
