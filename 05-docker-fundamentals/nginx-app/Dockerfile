FROM nginx:alpine

# Copy static HTML to Nginx public webroot
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
