docker rm -f vncbrave

docker run -d \
  --name vncbrave \
  -v vncbrave:/home/vncbrave/.config/BraveSoftware \
  -v /Volumes/Tmp:/home/vncbrave/Downloads \
  -p 5900:5900 \
  -e WIDTH=1024 -e HEIGHT=768 \
  tenox7/vncbrave:latest
