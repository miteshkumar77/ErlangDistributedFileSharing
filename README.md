# ErlangDistributedFileSharing

## Group Members

- Mitesh Kumar `<kumarm4>`
- Alex He `<hea2>`

## Features

- upload/download files from a distributed file store

## Known Bugs

- Getting a file before it exists will crash the servers
- DirService cannot process multiple downloads in parallel. It will cause
  non-deterministic results
