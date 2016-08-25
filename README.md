#Docker Jahia DX
This is a POC and it is not supported by Jahia.

##Software Dependencies
* Docker, https://www.docker.com/products/overview

##Docker Dependencies
* Data, storing binary files & generated resources, https://github.com/smomin/docker-digitalx-data
* MySQL, storing JCR data, https://github.com/smomin/docker-digitalx-mysql 
* Regis, distributed session, execute `docker run --name redis redis`

##How to Use
* Build an Image
  * Clone Docker DigitalX repo
  * Build the docker image,`docker build -t sajidmomin/digitalx`.
* To use existing image, execute below command.  For reference,   prebuild image is on https://hub.docker.com/r/sajidmomin/digitalx/. 
* Run docker container, `docker run -it -d -p 9088:8080 --link digitalx-mysql:mysql --link redis:redis --volumes-from digitalx-data --name digitalx sajidmomin/digitalx`
* Processing node: http://localhost:9088/
  * **NOTE**
If a browsing node is needed to joining the cluster, execute, `docker run -it -d -p 9089:8080 --link digitalx-mysql:mysql --link redis:redis --volumes-from digitalx-data --env BROWSING=true --name digitalx-browsing sajidmomin/digitalx`
 * Browsing node: http://localhost:9089/

