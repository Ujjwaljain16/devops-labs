FROM httpd:2.4-alpine

# Copy static webpage to Apache public HTML directory
COPY index.html /usr/local/apache2/htdocs/

EXPOSE 80

CMD ["httpd-foreground"]
