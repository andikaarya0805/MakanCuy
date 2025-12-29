
# Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
# Click nbfs://nbhost/SystemFileSystem/Templates/Other/Dockerfile to edit this template

FROM tomcat:10.1-jdk21

# 1. Bersih-bersih
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. DOWNLOAD LIBRARY JSTL (Biar JSP jalan)
ADD https://repo1.maven.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar /usr/local/tomcat/lib/jstl-api.jar
ADD https://repo1.maven.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar /usr/local/tomcat/lib/jstl-impl.jar

# 3. DOWNLOAD MYSQL DRIVER (INI KUNCI BIAR KONEK DB!)
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.2.0/mysql-connector-j-8.2.0.jar /usr/local/tomcat/lib/mysql-connector.jar

# 4. FIX IZIN BACA FILE
RUN chmod 644 /usr/local/tomcat/lib/jstl-api.jar && \
    chmod 644 /usr/local/tomcat/lib/jstl-impl.jar && \
    chmod 644 /usr/local/tomcat/lib/mysql-connector.jar

# 5. COPY APLIKASI
COPY dist/MakanCuy.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]