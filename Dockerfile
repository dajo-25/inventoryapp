# Etapa 1: Build de Flutter Web
FROM cirrusci/flutter:3.6.1-stable AS build

# Directorio de trabajo
WORKDIR /app

# Copiamos dependencias y hacemos pub get (cacheable)
COPY pubspec.* ./
RUN flutter pub get

# Copiamos el resto del código
COPY . .

# Compilamos para web en modo release
RUN flutter build web --release

# Etapa 2: Servir con Nginx
FROM nginx:stable-alpine

# Eliminamos la configuración por defecto
RUN rm /etc/nginx/conf.d/default.conf

# Copiamos nuestra configuración de Nginx
COPY nginx.conf /etc/nginx/conf.d/

# Copiamos los archivos generados por Flutter
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponemos el puerto que use Nginx
EXPOSE 80

# Arrancamos Nginx en foreground
CMD ["nginx", "-g", "daemon off;"]
