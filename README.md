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
