<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
	import="java.sql.Connection"
	import="java.sql.DriverManager"
	import="java.sql.ResultSet"
	import="java.sql.SQLException"
	import="java.sql.Statement"
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%

//Tomcat9(Java16)がターゲット

// mssql-jdbc-9.4.0.jre16.jar を (解凍先)\pleiades\tomcat\9\lib に置く

// mssql-jdbc-9.4.0.jre16.jar を (解凍先)\pleiades\workspace\WebConnectTest\src\main\webapp\WEB-INF\lib にも置く(必須ではない)

try{
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch(ClassNotFoundException e){
    e.printStackTrace();
    return;
}
String connectionUrl = "jdbc:sqlserver://INNO-04\\SQLEXPRESS;databaseName=TrainingDB3;user=sa;password=inno-vation";
try {
    Connection con = DriverManager.getConnection(connectionUrl);
    Statement stmt = con.createStatement();
    String SQL = "SELECT * FROM TEST_TABLE1";
    ResultSet rs = stmt.executeQuery(SQL);
    while (rs.next()) {
        System.out.println(rs.getString("TEST1") + " " + rs.getString("TEST2"));
%>
<p>
<%= rs.getString("TEST1") + " " + rs.getString("TEST2") %>
</p>
<%
    }
    rs.close();
    con.close();
}
catch (SQLException e) {
    e.printStackTrace();
}
%>
</body>
</html>