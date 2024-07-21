# transmission-replace.sh

The purpose of this small bash script is to replace the trackers URL inside a `.torrent` file with a new one.

This script was born in a few hours during a Sunday afternoon because I had a need to replace the trackers URL from several `.torrent` files.

You probably don't need this, because this is a really specific use case. But if it can help someone, somewhere, then why not share it?

# Dependencies

This script use `transmission-show` and `transmission-edit` which are parts of the [`transmission-cli`](https://packages.debian.org/search?keywords=transmission-cli) package.

# Limitations

- **all** trackers URL are deleted and replaced by a new one
- this script was only tested on Debian sid

# Usage

```shell
transmission-replace.sh: [options]

Options:
 -t --tracker <url>           Tracker URL to replace with
 -f --file    <torrent_file>  Specify a torrent file
 -v --verbose                 Show debug information
 -h --help                    Show this usage
```

# Examples

Basic usage : replace the tracker URL with "http://test.com:8080/announce" in the file `example.torrent` :

```
./transmission-replace.sh --tracker "http://test.com:8080/announce" --file "example.torrent"
```

Do this on all `.torrent` in current directory :

```
find . -maxdepth 1 -iname "*.torrent" -exec ./transmission-replace.sh --tracker "http://test.com:8080/announce" --file {} \;
```

Same but with [`fd`](https://github.com/sharkdp/fd) :

```
fd --max-depth 1 --extension torrent --exec ./transmission-replace.sh --tracker "http://test.com:8080/announce" --file {} \;
```

# TODO

- [ ] Add a `-b, --backup` argument to save the `.torrent` file before changing the tracker URL
- [ ] Add a `-c, --confirm` argument to force the user to confirm the change (?)
- [ ] Add a `-d, --dry-run` argument (?)

# License

[MIT License](./LICENSE)
