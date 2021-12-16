<!-- 

こちらは詳細画面(itiran2.jsp)で「更新・削除・登録」を行ったときに、
問題があると遷移するjspで、問題の内容と詳細画面に戻るボタンを表示します。

 -->
 
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>エラー画面</title>
	</head>
	<body>
		<%
		//詳細画面でのエラーがあれば表示
		
		if (session.getAttribute("numberEx") != null) {
			%>
			<p><%= session.getAttribute("numberEx")%></p>
		<%
		}
		
		if (session.getAttribute("parseEx") != null) {
			%>
			<p><%= session.getAttribute("parseEx")%></p>
		<%
		}
		
		if (session.getAttribute("nullEx") != null) {
			%>
			<p><%= session.getAttribute("nullEx")%></p>
		<%
		}
		
		if (session.getAttribute("kousuu_over") != null) {
			%>
			<p><%= session.getAttribute("kousuu_over")%></p>
		<%
		}
		
		if (session.getAttribute("bikou_over") != null) {
			%>
			<p><%= session.getAttribute("bikou_over")%></p>
		<%
		}
		
		if (session.getAttribute("anken_shosai_over") != null) {
			%>
			<p><%= session.getAttribute("anken_shosai_over")%></p>
		<%
		}%>
		
		
		<form action="shosai2.jsp" method="post">
			<%
			if (request.getParameter("fix_mode") != null) {
				%>
				<!-- 
					修正モード(登録ボタンを表示しない)で戻りたいため
					 hiddenをセット
				 -->
				<input type="hidden" name="fix">
				<%
			}
			%>
			<input type="submit" value="詳細画面に戻る">
		</form>
		
	</body>
</html>