freeStyleJob('storage-cleanup') {

  description('Deletes old images, dangling volumes and stopped containers')

  triggers {
    cron('H 8 * * 7')
  }

  steps {
    shell('''#!/bin/bash
containers=$(docker ps -q -f status=exited|wc -l)
if [ $containers -gt 0 ]; then
  docker rm $(docker ps -q -f status=exited)
else
  echo "No exited containers to remove"
fi

volumes=$(docker volume ls -f dangling=true -q|wc -l)
if [ $volumes -gt 0 ]; then
  docker volume rm $(docker volume ls -f dangling=true -q)
else
  echo "No dangling volumes to remove"
fi

images=$(docker images --quiet --filter "dangling=true"|wc -l)
if [ $images -gt 0 ]; then
  docker rmi $(docker images --quiet --filter "dangling=true")
else
  echo "No dangling images to remove"
fi

echo "Deleted $containers containers."
echo "Deleted $volumes volumes."
echo "Deleted $images images".''')
  }

 }
