<!-- 

一覧画面(itiran2.jsp)で「検索」ボタンを押したときに遷移するjspです。

指定された検索条件をセッションとしてセットし、もし検索エラーがあれば
それもセッションでセットします。
処理が終わると一覧画面に遷移します。

 -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.sql.Connection"
	import="java.sql.DriverManager" import="java.sql.ResultSet"
	import="java.sql.SQLException" import="java.sql.Statement"
	import="anken_kanri2.Edit2"%>
	
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>検索処理jsp</title>
	</head>	
	<body>
		<%
		String anken_name_itiran = null;
		String nouhin_date_from = null;
		String nouhin_date_to = null;
		String status_itiran = null;
		String tantou_name_itiran = null;
		int tmp = 0;
		request.setCharacterEncoding("utf-8");
		
		//案件名が100字を超えると検索エラー
		if(request.getParameter("anken_name_itiran").length() <= 100){
			if (!(request.getParameter("anken_name_itiran").equals(""))) {
				anken_name_itiran = request.getParameter("anken_name_itiran");
			} else {
				tmp++;
			}
	
		}else{
			session.setAttribute("anken_name_over", "案件名は100字以内で入力してください。");
		}
		
		//納品予定日検索の開始の日付の文字数が16字を超えているまたは日付として不適切な文字だと検索エラー
		if(request.getParameter("nouhin_date_from").length() <= 16){
			if (!(request.getParameter("nouhin_date_from").equals(""))) {
				if(Edit2.checkDate(request.getParameter("nouhin_date_from"))){
					nouhin_date_from = request.getParameter("nouhin_date_from");
				}else{
					session.setAttribute("incorrectFrom", "開始日が不正です。");
				}
			} else {
				tmp++;
			}
	
		}else{
			session.setAttribute("date_from_over", "納品開始日は16字以内で入力してください。");
		}
		
		//納品予定日検索の終了の日付の文字数が16字を超えているまたは日付として不適切な文字だと検索エラー
		if(request.getParameter("nouhin_date_to").length() <= 16){
			if (!(request.getParameter("nouhin_date_to").equals(""))) {
				if(Edit2.checkDate(request.getParameter("nouhin_date_to"))){
					nouhin_date_to = request.getParameter("nouhin_date_to");
				}else{
					session.setAttribute("incorrectTo", "終了日が不正です。");
				}
			} else {
				tmp++;
			}
	
		}else{
			session.setAttribute("date_to_over", "納品終了日は16字以内で入力してください。");
		}
	
		//ステータスが選択されていない(「選択してください」になっている)
		if (!(request.getParameter("status_itiran").equals("選択してください"))) {
			status_itiran = request.getParameter("status_itiran");
		} else {
			tmp++;
		}
	
		//担当者名の文字数が20字を超えていると検索エラー
		if(request.getParameter("tantou_name_itiran").length() <= 20){
			if (!(request.getParameter("tantou_name_itiran").equals(""))) {
				tantou_name_itiran = request.getParameter("tantou_name_itiran");
			} else {
				tmp++;
			}
	
		}else{
			session.setAttribute("tantou_name_over", "担当者名は20字以内で入力してください。");
		}
		
		//一覧画面の5つの検索条件が全て指定されていないと検索エラー
		if (tmp == 5) {
			session.setAttribute("notEnough", "いづれかの検索条件を指定してください。");
		}
	
		session.setAttribute("anken_name_search", anken_name_itiran);
		session.setAttribute("date_from_search", nouhin_date_from);
		session.setAttribute("date_to_search", nouhin_date_to);
		session.setAttribute("status_search", status_itiran);
		session.setAttribute("tantou_name_search", tantou_name_itiran);
		%>
		
		<jsp:forward page="itiran2.jsp" />
	</body>
</html>