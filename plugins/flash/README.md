# Flash
Sends a requested text file to the calling client

## Configuration
By default will search plugin-managers root directory for `flash-files/`. Flash will not follow simlinks for do a recursive search.

You can also override the default search path by putting `flash.conf` in plugin-managers root directory with:
```
search_dir="YOUR PATH"
```

## Usage

### JSON Request Format
`file`: String to the file you would like to access. Required when `kind`: "download".

### JSON Response Format
`status`: "ok" | "error"

`kind`: See request

`cause`: If `status`: "error" then contains a string explaining the error

`files`: If `status`: "query" then contains a string array of all known files

or

`text`: If `status`: "download" then contains string of contents of file
