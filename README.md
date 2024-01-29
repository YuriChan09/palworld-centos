# palworld-centos
A script to deploy a Palworld server on CentOS. The server will run as a systemd service named pal-server.service and is configured to automatically restart 30 seconds after a crash.

## How to use
Connect to your server, then type
```bash
wget -O - xxx.sh|sh
```
Don't forget to allow UDP on port 8211.
## Thanks
[Palworld Server One-Click Deployment On Ubuntu](https://cloud.tencent.com/developer/article/2382000)
 
