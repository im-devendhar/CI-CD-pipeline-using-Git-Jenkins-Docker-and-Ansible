FROM tomcat:9.0

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Change Tomcat port from 8080 → 8090
RUN sed -i 's/port="8080"/port="8090"/' /usr/local/tomcat/conf/server.xml

# Copy your app
COPY src/main/webapp/index.jsp /usr/local/tomcat/webapps/ROOT/index.jsp

# Expose port 8090
EXPOSE 8090
