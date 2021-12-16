<!-- 

システムのメインとなる画面を表示するjspです。
社内案件を、「登録・検索・修正」操作することが出来ます。

・「案件を新規登録」ボタンを押すと、詳細画面(shosai2.jsp)に遷移します。
・検索条件は5つ指定でき、「検索」ボタンを押すと検索処理jsp(kensaku.jsp)へ遷移し、
当画面へ検索結果を表示します。なお、検索時エラーがあった場合は当画面のエラーメッセージ横へ
エラーの内容を表示し、検索は行われません。
・「修正」ボタンを押すと、そのNoのデータを取得し、ArrayListに入れセッションをセットし、
詳細画面に遷移します。

 -->
 
 <!-- TODO テキストボックス表示位置を揃えるcss -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.sql.Connection"
	import="java.sql.DriverManager" import="java.sql.ResultSet"
	import="java.sql.SQLException" import="java.sql.Statement"
	import="java.util.ArrayList" import="java.util.HashMap"%>
<%@ page isErrorPage="true"%>

<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="anken2.css">
		<meta charset="UTF-8">
		<title>検索・一覧画面</title>
	</head>
	<%!
		String SQL = null;
	
		//DB接続用定数
	    String DATABASE_NAME = "portfolio";
	    String PROPATIES = "?characterEncoding=UTF-8";
	    String URL = "jdbc:mySQL://localhost:4000/" + DATABASE_NAME+PROPATIES;
	    //DB接続用・ユーザ定数
	    String USER = "root";
	    String PASS = "aiueo300";
	    
		Connection con = null;
		Statement stmt = null;
		ResultSet rs = null;
	%>
	
	<%
		ArrayList<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();
		String[] col = { "案件ID", "案件名", "ステータス", "優先度", "納品予定日", "予定工数", "担当者" };
		int cnt = 0;
		try {
			Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	%>
	<%
		//詳細画面での条件指定値は一覧画面では必要ないのでremove
		session.removeAttribute("anken_name_shosai");
		session.removeAttribute("status_name_shosai");	
		session.removeAttribute("priority_shosai");
		session.removeAttribute("anken_date_shosai");
		session.removeAttribute("anken_kousuu_shosai");
		session.removeAttribute("tantou_name_shosai");
		session.removeAttribute("bikou_shosai");
	%>
	<body>
		<div class="window" style="border: 1px dotted #333333;">
			<div class="btn_right">
				<form action="shosai2.jsp">
					<input type="submit" value="案件を新規登録" class="margin_r margin_t" name="new" style="width:150px;height:25px">
				</form>
			</div>
			<form action="kensaku.jsp" method="post">
				<span class="margin_l" style="font-weight: bold">検索条件</span><br>
				<span class="margin_r margin_l" style="font-weight: bold">案件名　    </span>
				<input type="text" name="anken_name_itiran" class="margin_r" 
				value="<% if(session.getAttribute("anken_name_search") != null){out.println(session.getAttribute("anken_name_search"));}%>"> 
				<span style="font-weight: bold">納品予定日</span>
				<input type="text" name="nouhin_date_from" placeholder="ex)2010/02/12 or2010-02-12"
				value="<% if(session.getAttribute("date_from_search") != null){out.println(session.getAttribute("date_from_search"));}%>"> 
				<span>～</span>
				<input type="text" name="nouhin_date_to" class="margin_r" placeholder="ex)2010/02/12 or2010-02-12"
				value="<% if(session.getAttribute("date_to_search") != null){out.println(session.getAttribute("date_to_search"));}%>">
				<span style="font-weight: bold">ステータス</span>
				<%
				try {
					con = DriverManager.getConnection(URL, USER, PASS);
					stmt = con.createStatement();
					System.out.println("データベース接続に成功");
					SQL = "SELECT * FROM status_table";
					rs = stmt.executeQuery(SQL);
				%>
				<select name="status_itiran">
					<option>選択してください</option>
					<%
					while (rs.next()) {
					%>
					<option <%if(session.getAttribute("status_search") != null){
								if(session.getAttribute("status_search").equals(rs.getString("status_name"))){
								%>selected<%
								}
							}%>>
						<%=rs.getString("status_name")%>
					</option>
					<%}
					rs.close();
					con.close();
					%>
				</select><br> <span class="margin_l margin_r" style="font-weight: bold">担当者名</span>
				<input type="text" name="tantou_name_itiran"
				value="<% if(session.getAttribute("tantou_name_search") != null){out.println(session.getAttribute("tantou_name_search"));}%>">
				<br>
				<div class="btn_right">
					<input type="submit" value="検索" class="margin_r" name="search_itiran" style="width: 80px;height: 25px">
				</div>
			</form>
			<span class="margin_l" style="font-weight: bold">エラーメッセージ：</span>
			<span>
				<%
				//検索時のエラーをある分だけ表示
				if(session.getAttribute("anken_name_over") != null){
					%>
				<span><%= session.getAttribute("anken_name_over")%></span>
				<%}
				if(session.getAttribute("notEnough") != null){
					%>
				<span><%= session.getAttribute("notEnough")%></span>	
				<%}
				if(session.getAttribute("date_from_over") != null){
					%>
				<span><%= session.getAttribute("date_from_over")%></span>	
				<%}
				
				if(session.getAttribute("date_to_over") != null){
					%>
				<span><%= session.getAttribute("date_to_over")%></span>	
				
				<%}
				if(session.getAttribute("tantou_name_over") != null){
					%>
				<span><%= session.getAttribute("tantou_name_over")%></span>
				<%}
				if(session.getAttribute("incorrectFrom") != null){
					%>
				<span><%= session.getAttribute("incorrectFrom")%></span>
				<%}
				if(session.getAttribute("incorrectTo") != null){
					%>
				<span><%= session.getAttribute("incorrectTo")%></span>
				
				<%}
				} catch (SQLException e) {	
					out.println(e);
				}
				%>
			</span>
			<hr class="margin_t margin_b">
			<span class="margin_l" style="font-weight: bold">検索結果</span><br>
			<table border="1" width="1220px" style="border-collapse: collapse" class="margin_l margin_r">
				<tr id="table_head">
					<th width="70px">　</th>
					<th align="left">No</th>
					<th align="left">案件名</th>
					<th align="left">ステータス</th>
					<th align="left">優先度</th>
					<th align="left">納品予定日</th>
					<th align="left">予定工数</th>
					<th align="left">担当者</th>
				</tr>
			<%
			try {
					con = DriverManager.getConnection(URL, USER, PASS);
					stmt = con.createStatement();
					//検索で最低でも一つは条件があって
					if (!(session.getAttribute("anken_name_search") == null && session.getAttribute("date_from_search") == null
						&& session.getAttribute("date_to_search") == null && session.getAttribute("status_search") == null
						&& session.getAttribute("tantou_name_search") == null)) {
						//かつ一つも検索エラーが無いとき
						if(session.getAttribute("anken_name_over") == null && session.getAttribute("date_from_over") == null &&
							session.getAttribute("date_to_over") == null && session.getAttribute("tantou_name_over") == null &&
							session.getAttribute("incorrectFrom") == null && session.getAttribute("incorrectTo") == null){
							SQL = "SELECT * FROM project_table PT ";
							SQL += "LEFT JOIN status_table ST "; 
							SQL += "ON PT.status_id = ST.status_id ";  
							SQL += "LEFT JOIN Staff_master SM "; 
							SQL += "ON SM.staff_id = PT.contact_id "; 
							SQL += "WHERE ";
							String[] attributes = { (String) session.getAttribute("anken_name_search"),
							(String) session.getAttribute("date_from_search"), (String) session.getAttribute("date_to_search"),
							(String) session.getAttribute("status_search"), (String) session.getAttribute("tantou_name_search") };
							int tmp = 0;
							for (int i = 0; i < attributes.length; i++) {
								if (attributes[i] != null) {
									//一つ目の検索条件
									if (tmp == 0) {
										if (i == 0) {
											SQL += "project_title LIKE '" + session.getAttribute("anken_name_search") + "%'";
										}
										if (i == 1) {
											SQL += "delivery_date >= '" + session.getAttribute("date_from_search") + "'";
										}
										if (i == 2) {
											SQL += "delivery_date <= '" + session.getAttribute("date_to_search") + "'";
										}
										if (i == 3) {
											SQL += "status_name = '" + session.getAttribute("status_search") + "'";
										}
										if (i == 4) {
											SQL += "CONCAT(last_name, first_name) = '" + session.getAttribute("tantou_name_search") + "'";
										}
										tmp++;
									//二つ目以降の検索条件	
									} else {
										SQL += " AND ";
										if (i == 1) {
											SQL += "delivery_date >= '" + session.getAttribute("date_from_search") + "'";
										}
										if (i == 2) {
											SQL += "delivery_date <= '" + session.getAttribute("date_to_search") + "'";
										}
										if (i == 3) {
											SQL += "status_name = '" + session.getAttribute("status_search") + "'";
										}
										if (i == 4) {
											SQL += "CONCAT(last_name, first_name) ='" + session.getAttribute("tantou_name_search") + "'";
										}
									}
								}
							}
						}	
							
					}
					
					//検索条件によってエラーメッセージを変動させるためremove
					session.removeAttribute("notEnough");	
					session.removeAttribute("anken_name_over");
					session.removeAttribute("date_from_over");
					session.removeAttribute("date_to_over");
					session.removeAttribute("tantou_name_over");
					session.removeAttribute("incorrectFrom");
					session.removeAttribute("incorrectTo");	
					
				
					rs = stmt.executeQuery(SQL);
					while (rs.next()) {
						//「修正」が押されたときにデータを詳細画面に移行するためにArrayListに保存
						for (int i = 0; i < col.length; i++) {
							HashMap<String, String> map = new HashMap<String, String>();
							map.put(col[i++], rs.getString("item_id"));
							map.put(col[i++], rs.getString("project_title"));
							map.put(col[i++], rs.getString("status_name"));
							map.put(col[i++], rs.getString("priority"));
							map.put(col[i++], rs.getString("delivery_date"));
							map.put(col[i++], rs.getString("man_hour"));
							map.put(col[i++], rs.getString("contact_id"));
		
							list.add(map);
						}
		
						session.setAttribute("array", list);
					%>
			
						<tr>
							<td>
								<div style="display: inline-flex">
									<form action="shosai2.jsp" method="post">
										<input type="hidden" name="button_num" value="<%=++cnt%>">
										<input type="submit" name="fix" value="修正" class="button"
											style="border: none; background: #c0c0c0; width: 70px;">
									</form>
								</div>
							</td>
							<!-- 検索結果に基づいてデータベースのデータを表示 -->
							<td><%=cnt%></td>
							<td><%=rs.getString("project_title")%></td>
							<td><%=rs.getString("status_name")%></td>
							<td><%=rs.getString("priority")%></td>
							<td><%=rs.getString("delivery_date")%></td>
							<td><%=rs.getString("man_hour")%></td>
							<td><%=rs.getString("last_name") + rs.getString("first_name")%></td>
						</tr>
						<%
					}
		
					rs.close();
					con.close();
				} catch (SQLException e) {
				e.printStackTrace();
				}
				%>
	
	
			</table>
		</div>
	</body>
</html>