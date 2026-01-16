# Infraestructura de despliegue Omeka-S

## Descripción

El presente repositorio contiene los archivos de configuración de infraestructura 
y despliegue de Omeka-S, que cumple la función de repositorio de recursos digitales 
para su consulta a través del portal web desarrollado como parte del sistema para el 
Concurso de Oposición Abierto para ocupar una plaza de Técnico Académico Ordinario,
Asociado "C", de Tiempo Completo, Interino en el área de Programación en el Departamento
de Cómputo del Instituto de Investigaciones Sociales, con número de registro
02002-28.

Los otros componentes que forman parte del proyecto son:

Componente  | Enlace al repositorio
------------|--------------------------
Portal web desarrollado en Vue.js 3 |  https://github.com/michcatg/front-coa-iis
CMS Headless (Strapi)   | https://github.com/michcatg/strapi-coa

El objetivo de este repositorio es permitir el despliegue de Omeka-S mediante
contenedores Docker, utilizando imágenes propias, conforme a las bases del concurso. Asímismo,
el repositorio incluye Los archivos necesarios para la creación de las imagenes.

> **Nota importante:**  
> El código fuente de Omeka-S no fue modificado. Es por este motivo que 
> el código fuente no forma parte del contenido y el repositorio contiene únicamente la configuración
> necesaria para su despliegue mediante Docker y Docker Compose.

## Componentes del despliegue

El despliegue de Omeka-S se realiza construyendo contenedores a partir de las siguientes imagenes:

- **Servidor web (Nginx)**  
  Imagen: https://hub.docker.com/r/mitchcatg/omekas-nginx
  Archivo de construcción: [Containerfile.nginx](Containerfile.nginx)

- **Servicio de procesamiento de la aplicación (PHP)**  
  Imagen: https://hub.docker.com/r/mitchcatg/omekas-site
  Archivo de construcción: [Containerfile.site](Containerfile.site)

- **Sistema manejador de base de datos**  
  La base de datos requerida por Omeka-S no se despliega con archivos de configuración presentes en este repositorio, ya que, conforme a las bases de la convocatoria, se encuentra en un sistema aislado. No obstante, se puede poner en marcha un contenedor de la imagen de MariaDB en cualquier host accesible desde la red por el servidor de despliegue actual (ver la sección [Despliegue del Sistema manejador de base de datos (opcional)](#despliegue-del-sistema-manejador-de-base-de-datos-opcional)).
  Se deberá considerar la importación de datos si corresponde al caso.

---

## Requisitos

Para el despliegue de Omeka-S es necesario contar con:

- Docker
- Docker Compose
- Acceso a una base de datos compatible con Omeka-S (MySQL/MariaDB)
- Acceso a un sistema de almacenamiento para archivos digitales
- Sistema operativo Linux
- Proxy inverso Traefik debidamente configurado.
- Dominio (real o de pruebas) para registrar el servicio en el proxy

> **Nota:**   
> Si se requiere acceder a Omeka-S fuera del contexto de un servidor proxy inverso, será necesario exponer el puerto correspondiente del contenedor para permitir el acceso directo desde el exterior.

## Instalación y despliegue
1. Clonar el repositorio   
  ```sh
  git clone https://github.com/michcatg/omekas-infrastructure.git
  cd omekas-infrastructure
  ```
2. Crear y configurar el archivo .env con los valores correspondientes al entorno. Tomar como plantilla el archivo [.env.example](.env.example)

3. Descargar y extraer el *release* empaquetado de OmekaS v4.2.0 desde su repositorio oficial https://github.com/omeka/omeka-s/releases/download/v4.2.0/omeka-s-4.2.0.zip   
  ```sh
  wget https://github.com/omeka/omeka-s/releases/download/v4.2.0/omeka-s-4.2.0.zip
  unzip omeka-s-4.2.0.zip
  ```
4. Copiar el archivo de configuración de base de datos database.ini en OmekaS   
  ```sh
  cp database.ini omeka-s/config/
  ```
5. Dar permisos de escritura al directorio de volumen de archivos de carga de Omeka S configurado en la variable de entorno `RESOURCE_FILES_DIR`. Se deberá considerar la importación de archivos si corresponde al caso.

6. Ejecutar el despliegue con Docker Compose:
  ```sh
  docker compose -f compose.yml -f compose_prod.yml up -d
  ```
## Despliegue del Sistema manejador de base de datos (opcional)

Las formas de desplegar la base de datos pueden variar según el entorno. En caso de requerir su implementación mediante contenedores, se debe ejecutar el siguiente comando:

```sh
# Despliegue de mariaDB a través de contenedor
docker run -d \
  --name mariadb-omekas \
  --env-file .env \
  -v "$(pwd)/mariadb-data:/var/lib/mysql" \
  mariadb:11.7.2
```
> **Nota importante:**
>
> Se debe de configurar las variables `MARIADB_USER`, `MARIADB_PASSWORD`y `MARIADB_DATABASE` con los datos de conexión que se utilizarán con Omeka S, adicional a `MARIADB_ROOT_PASSWORD`

**Medida de seguridad recomendada:**
 
Idealmente el servidor de base de datos debería de desplegarse en una red aislada y segura, no obstante, es importante tomar en cuenta que por defecto, los usuarios de la base de datos creado por la imagen oficial de MariaDB puede conectarse desde cualquier host (usuario@%).

Para mejorar la seguridad, se recomienda eliminar este usuario y crear uno nuevo que solo pueda conectarse desde el host de despliegue (por ejemplo, usuario@localhost o usuario@ip_del_servidor). Esto limitará el acceso del usuario únicamente desde el host autorizado. Esto se puede realizar accediendo al contenedor, adaptando y ejecutando los siguientes comandos en MariaDB:

```sql
DROP USER 'username'@'%';
CREATE USER 'username'@'localhost' IDENTIFIED BY 'tu_contraseña';
GRANT ALL PRIVILEGES ON omekas.* TO 'username'@'localhost';
FLUSH PRIVILEGES;
```
Se deberá de considerar la importación de datos en caso de que aplique.