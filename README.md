# goproxy.sh


goproxy.sh is a shell script to help in creating a file/disk based Go module proxy.  

A Go module proxy is any web server(or file location) that can respond to GET requests for URLs of a specified form.    
The requests have no query parameters,  
so even a site serving from a fixed file system (including a file:/// URL)
can be a module proxy.

The go command by default downloads modules from version control systems  
directly, just as 'go get' always has.     
The GOPROXY environment variable allows further control over the download source.    
GOPROXY is expected to be the URL of a module proxy, in which case the go command will fetch all modules from that proxy.


# Installation:
- clone this repository(or copy the contents of the ` goproxy.sh` file)       
- make the `goproxy.sh` file executable;  
```bash
chmod +x  goproxy.sh  
```

# Usage:  
```bash
./goproxy.sh -l /tmp/myGoProxy -m github.com/pkg/errors -v v0.8.0
```
where;  
- `l` is the location on disk/file where you want to create the Go module proxy.  
- `m` is the module you want to add to the module proxy.   
- `v` is the version of that module that you want to add to the module proxy.     

Then use your Go proxy with your usual Go commands;   
```bash
export GOPROXY=file:////tmp/myGoProxy && go get github.com/pkg/errors
```
..
```bash
export GOPROXY=file:////tmp/myGoProxy && go run main.go
```

**NB:** 
- It currently only works with modules that are hosted on github.
- It is an experiment, it works for simple modules but should not be used in production or with code that you care about. Use it only as an inspiration to build upon.
- It is not feature complete. For example the documentation for the GOPROXY protocol; https://go.dev/ref/mod#goproxy-protocol says:
```
To avoid ambiguity when serving from case-insensitive file systems, the $module and $version elements are case-encoded by replacing every uppercase letter with an exclamation mark followed by the corresponding lower-case letter. This allows modules example.com/M and example.com/m to both be stored on disk, since the former is encoded as example.com/!m.
```
`goproxy` does not cover this edge case among others.
- It might be easier to leverage the default Go proxy to create for you a file based proxy;
```sh
# A. Using the machine that has internet connection, run these commands:

# Unset the default Golang paths and proxies.
sudo rm -rf /tmp/myGoProxy/
mkdir -p /tmp/myGoProxy/
unset GOPROXY
unset GOPATH

# Set Golang proxy to the default one.
# Set GOPATH to a custom path
export GOPROXY='https://proxy.golang.org,direct'
export GOPATH=/tmp/myGoProxy/

# Populate our custom GOPATH with modules.
go mod download
go mod tidy

# Check that our custom directory has been populated.
tree /tmp/myGoProxy/pkg/mod/cache/download

# Unset Go env variables
unset GOPROXY
unset GOPATH

# B. Copy the `/tmp/myGoProxy/pkg/mod/cache/download` directory to the machine with no internet connection.

# C. Run the following commands in the machine with no internet connection;

# Set proxy to point to our custom directory.
export GOPROXY='/tmp/myGoProxy/pkg/mod/cache/download'
go build .  
```
