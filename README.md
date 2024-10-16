# EcoSensor stack

Ecosensor stack for an AWS EC2 instance that starts the script `aws/user-data.sh`.

Before starting the stack, if you need to use docker-compose you need to copy _env.template_ files to _.env_ file and add your password database.

```bash
docker-compose --profile all up -d
```