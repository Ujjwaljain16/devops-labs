FROM nginx:alpine

# Copy static React SPA into Nginx document root
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
