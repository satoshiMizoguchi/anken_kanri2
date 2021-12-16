<!--

こちらは検索・一覧画面(itiran2.jsp)で「修正・案件を新規登録」ボタンを押したときに
遷移するjspです。

・「案件を新規登録」ボタンが押された際は、データベースでプライマリキーである
案件IDのみ重複・編集できないようセットされます。
・「修正」ボタンが押された際は、押されたボタンの行のデータをデータベースより取得し、
テキストボックスやテキストエリアなどにセットします。

ボタンは4つありますが、
・「キャンセル」ボタンは、常時表示で押すと一覧画面へ遷移します。
・「更新・削除」ボタンは、検索・一覧画面で「修正」ボタンを押したときのみ表示します。
・「登録」ボタンは、検索・一覧画面で「案件を新規登録」ボタンを押したときのみ表示します。

「更新・登録」ボタンを押すと更新・登録処理サーブレット(Edit2.java)に遷移します。

  -->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.sql.Connection"
	import="java.sql.DriverManager" import="java.sql.ResultSet"
	import="java.sql.SQLException" import="java.sql.Statement"
	import="javax.servlet.RequestDispatcher" import="java.util.HashMap"
	import="java.util.ArrayList" import="java.util.Objects"
	import="java.util.*"%>
	
<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="anken2.css">
		<meta charset="UTF-8">
		<title>詳細画面</title>
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
		int max = 0;
		HashMap<String, String> hashMap = null;
		ArrayList<HashMap<String, String>> list = null;
	%>
		
	<!-- 「更新・削除・登録」ボタンを押すと表示する確認ダイアログ -->	
	<script type="text/javascript">
		function cancelsubmit() {
			if (confirm("実行してもよいですか")) {
				window.location.href = "Edit2";
			}
		}
	</script>
	<!-- 詳細画面に修正ボタンで遷移したのかどうか -->
		<%
			if (request.getParameter("fix") != null) {
				if (!(Objects.isNull(request.getParameter("button_num")))) {
					hashMap = new HashMap<String, String>();
					list = (ArrayList<HashMap<String, String>>) session.getAttribute("array");
					hashMap = list.get(Integer.parseInt(request.getParameter("button_num")) - 1);
				}		
			}
		
			try {
				Class.forName("com.mysql.jdbc.Driver");
			} catch (ClassNotFoundException e) {
				e.printStackTrace();
			}
		%>
		<%
			//検索画面での検索条件は詳細画面では必要ないのでremove
			session.removeAttribute("anken_name_search");
			session.removeAttribute("date_from_search");
			session.removeAttribute("date_to_search");
			session.removeAttribute("status_search");
			session.removeAttribute("tantou_name_search");		
		%>
	
	<body>
		<div class="window"
			style="padding: 30px 60px;border: 1px dotted #333333;">
			<form action="Edit2" method="get" onsubmit="return cancelsubmit()">
				<span style="font-weight: bold">案件ＩＤ　　　</span>
				<%
				try {
					con = DriverManager.getConnection(URL, USER, PASS);
					stmt = con.createStatement();
					//修正ボタンで遷移したので、DBのデータから案件IDをセット
					if (request.getParameter("fix") != null) {
						SQL = "SELECT * FROM project_table ";
						SQL += "WHERE item_id = ";
						SQL += hashMap.get("案件ID");
						rs = stmt.executeQuery(SQL);
						while (rs.next()) {
							%>
							<input type="hidden" name="anken_id_shosai"
								value="<%=rs.getString("item_id")%>">
							<span readonly="readonly" class="margin_r" style="border-bottom: solid thin;"><%=rs.getString("item_id")%></span>	
							<%
						}
					//新規登録ボタンで遷移したので、DBの既存データの案件IDの最大値+1をセット		
					} else {
						SQL = "SELECT item_id FROM project_table";
						rs = stmt.executeQuery(SQL);
						while (rs.next()) {
							if (rs.getInt("item_id") >= max) {
								max = rs.getInt("item_id");
							}
						}
						%>
			
						<input type="hidden" name="anken_id_shosai"
							 value=<%=max + 1%>>
							 <span readonly="readonly" class="margin_r" style="border-bottom: solid thin;"><%=max + 1%></span>	
						<%
					}
					%>
	
					<span>※変更不可</span><br><br>
					<%
				} catch (SQLException ex) {
				System.out.println("エラー出てるよ");	
				ex.printStackTrace();
				}
				%>
	
				<span style="font-weight: bold">案件名　　　　</span>
				<%
				//修正ボタンで遷移の時はDBのデータをセット 以下※１
				if (request.getParameter("fix") != null) {
				%>
				<input type="text" name="anken_name_shosai" 
					class="margin_r" size="50"
					value="<%if(session.getAttribute("anken_name_shosai") != null){
								if(session.getAttribute("anken_shosai_over") == null){
									out.println(session.getAttribute("anken_name_shosai"));
								}	
							}else{
								out.println(hashMap.get("案件名"));
							}%>">
	
				<%
				//新規登録ボタンで遷移の時はなにもセットしない 以下※２
				} else {
				%>
				<input type="text" name="anken_name_shosai" 
					class="margin_r" size="50" 
					value="<%if(session.getAttribute("anken_name_shosai") != null){
								if(session.getAttribute("anken_shosai_over") == null){
									out.println(session.getAttribute("anken_name_shosai"));
								}	
							}%>">
				<%
				}
				%><span>※必須入力</span><br>
				<br> <span style="font-weight: bold">ステータス　　</span>
	
	
	
				<%
				try {
					con = DriverManager.getConnection(URL, USER, PASS);
					stmt = con.createStatement();
					SQL = "SELECT * FROM status_table";
					rs = stmt.executeQuery(SQL);
				%>
				<select name="status_name_shosai" class="margin_r">
					<option>選択してください</option>
	
					<%
					//※１
					if (request.getParameter("fix") != null) {
						while (rs.next()) {
						%>
						<option
							<%if(session.getAttribute("status_name_shosai") != null){
								if(!(session.getAttribute("status_name_shosai").equals(""))){
									if(session.getAttribute("status_name_shosai").equals(rs.getString("status_name"))){
									%>selected<%
									}
								 }
							}
							else{
								if(rs.getString("status_name").equals(hashMap.get("ステータス"))) {
									%>selected<%
								}
							}%>><%=rs.getString("status_name")%></option>
						<%
					}
					//※２	
					}else {
						while (rs.next()) {
						%>
						<option <%if(session.getAttribute("status_name_shosai") != null){
							if(!(session.getAttribute("status_name_shosai").equals(""))){
							if(session.getAttribute("status_name_shosai").equals(rs.getString("status_name"))){
							%>selected<%}}} %>><%=rs.getString("status_name")%>
						</option>
						<%
						}
					}
					
	
					rs.close();
					 con.close();
				%>
				</select><span>※必須選択</span>
				<%
				} catch (SQLException e) {
				e.printStackTrace();
				}
				%>
				<br>
				<br> <span style="font-weight: bold">優先度　　　　</span> <select
					name="priority_shosai">
					<option>選択してください</option>
					<%
					//※１
					if (request.getParameter("fix") != null) {
						%>
						<option value="1" 
						<%if(session.getAttribute("priority_shosai") != null){
							if("1".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("1".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>1</option>
						<option value="2"
						<%if(session.getAttribute("priority_shosai") != null){
							if("2".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("2".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>2</option>
						<option value="3"
						 <%if(session.getAttribute("priority_shosai") != null){
							if("3".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("3".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>3</option>
						<option value="4"
						<%if(session.getAttribute("priority_shosai") != null){
							if("4".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("4".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>4</option>
						<option value="5"
						<%if(session.getAttribute("priority_shosai") != null){
							if("5".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("5".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>5</option>
						<option value="6"
						<%if(session.getAttribute("priority_shosai") != null){
							if("6".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("6".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>6</option>
						<option value="7"
						<%if(session.getAttribute("priority_shosai") != null){
							if("7".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("7".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>7</option>
						<option value="8"
						<%if(session.getAttribute("priority_shosai") != null){
							if("8".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("8".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>8</option>
						<option value="9"
						<%if(session.getAttribute("priority_shosai") != null){
							if("9".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("9".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>9</option>
						<option value="10"
						<%if(session.getAttribute("priority_shosai") != null){
							if("10".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}else if("10".equals(hashMap.get("優先度"))) {%>
								selected <%;
						}%>>10</option>
						<%
					//※２
					} else {
						%>
						<option value="1" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("1".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>1</option>
						<option value="2" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("2".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>2</option>
						<option value="3" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("3".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>3</option>
						<option value="4" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("4".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>4</option>
						<option value="5" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("5".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>5</option>
						<option value="6" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("6".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>6</option>
						<option value="7" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("7".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>7</option>
						<option value="8" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("8".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>8</option>
						<option value="9" 
							<%if(session.getAttribute("priority_shosai") != null){
								if("9".equals(session.getAttribute("priority_shosai"))){
									%>selected<%
								}
							}%>>9</option>
						<option value="10" 
						<%if(session.getAttribute("priority_shosai") != null){
							if("10".equals(session.getAttribute("priority_shosai"))){
								%>selected<%
							}
						}%>>10</option>
						<%
					}%>
					
				</select><br>
				<br> <span style="font-weight: bold">納品予定日　　</span>
				<%
				//※１
				if (request.getParameter("fix") != null) {
					//入力必須じゃない項目がnullかどうか
					if (!(Objects.isNull(hashMap.get("納品予定日")))) {
				%>
						<input type="text" name="anken_date_shosai" 
							class="margin_r" 
							value="<%if(session.getAttribute("anken_date_shosai") != null){
										if(session.getAttribute("parseEx") == null){
											out.println(session.getAttribute("anken_date_shosai"));
										}	
									}else{out.println(hashMap.get("納品予定日"));
									}%>">
						<%
					} else {
						%>
						<input type="text" name="anken_date_shosai" 
							class="margin_r" 
							value="<%if(session.getAttribute("anken_date_shosai") != null){
										if(session.getAttribute("parseEx") == null){
											out.println(session.getAttribute("anken_date_shosai"));
										}	
									}%>">
			
					<%
					}
				//※２	
				} else {
					%>
					<input type="text" name="anken_date_shosai" 
						class="margin_r"
						value="<%if(session.getAttribute("anken_date_shosai") != null){
									if(session.getAttribute("parseEx") == null){
										out.println(session.getAttribute("anken_date_shosai"));
									}
								}%>">
					<%
				}
				%><span>※半角で入力 ex)2010/02/20</span><br>
				<br> <span style="font-weight: bold">予定工数　　　</span>
				<%
				//※１
				if (request.getParameter("fix") != null) {
						if (!(Objects.isNull(hashMap.get("予定工数")))) {
					%>
					<input type="text" name="anken_kousuu_shosai" 
						value="<%if(session.getAttribute("anken_kousuu_shosai") != null){
									if(session.getAttribute("kousuu_over") == null && session.getAttribute("numberEx") == null){
										out.println(session.getAttribute("anken_kousuu_shosai"));
									}	
								}else{out.println(hashMap.get("予定工数"));
								}%>">
					<%
						}else{
					%>
					<input type="text" name="anken_kousuu_shosai" 
						class="margin_r" 
						value="<%if(session.getAttribute("anken_kousuu_shosai") != null){
									if(session.getAttribute("kousuu_over") == null && session.getAttribute("numberEx") == null){
										out.println(session.getAttribute("anken_kousuu_shosai"));
									}	
								}%>">
					<%
						}
					//※２	
				} else {
				%>
				<input type="text" name="anken_kousuu_shosai" 
				value="<%if(session.getAttribute("anken_kousuu_shosai") != null){
							if(session.getAttribute("kousuu_over") == null && session.getAttribute("numberEx") == null){
								out.println(session.getAttribute("anken_kousuu_shosai"));
							}	
						}%>">
				<%
				}
				%>
				<br>
				<br> <span style="font-weight: bold">担当者　　　　</span>
				<%
				try {
					con = DriverManager.getConnection(URL, USER, PASS);
					stmt = con.createStatement();
					SQL = "SELECT * FROM Staff_master";
					rs = stmt.executeQuery(SQL);
				%>
				<select name="tantou_name_shosai">
					<option>選択してください</option>
	
					<%
					//※１
					if (request.getParameter("fix") != null) {
						while (rs.next()) {
							%>
							<option
								<%if (rs.getString("staff_id").equals(hashMap.get("担当者"))) {%>
									selected <%}%>><%= rs.getString("last_name") + rs.getString("first_name")%>
							</option>
							<%
						}
					//※２	
					} else {
						while (rs.next()) {
							%>
							<option><%= rs.getString("last_name") + rs.getString("first_name")%></option>
							<%
						}
					}
					
	
				   rs.close(); 
				   con.close();%>
				</select>
				<%
				} catch (SQLException e) {
				e.printStackTrace();
				}
				%>
				<br>
				<br> <span style="font-weight: bold">備考　　　　　</span>
				<textarea rows="6" cols="100" name="bikou_shosai" class="margin_b" style="vertical-align:top"><%
				//※１
					if (request.getParameter("fix") != null) {
						if(session.getAttribute("bikou_shosai") != null){
							if(session.getAttribute("bikou_over") == null){
								out.println(session.getAttribute("bikou_shosai"));	
							}
						}else{
							try {
								con = DriverManager.getConnection(URL, USER, PASS);
								stmt = con.createStatement();
								SQL = "SELECT * FROM project_table ";
								SQL += "WHERE item_id = ";
								SQL += hashMap.get("案件ID");
								rs = stmt.executeQuery(SQL);
								while (rs.next()) {
									out.println(rs.getString("remarks"));
								}
								rs.close();
								con.close();
							} catch (SQLException e) {
								e.printStackTrace();
							}
						}						
					//※２	
					}else{
						if(session.getAttribute("bikou_shosai") != null){
							if(session.getAttribute("bikou_over") == null){
								out.println(session.getAttribute("bikou_shosai"));
							}			
						}
					}%>
				</textarea><br><br>
				<div style="text-align: center;">
					<span class="margin_r" style="margin-left: 200px;">
						<input type="button" onclick="location.href='itiran2.jsp'"
						value="キャンセル" name="cancel">
					</span> 
					<span class="margin_r"> 
					
						 <%
						 //修正のときだけ更新ボタンを表示
						 if (request.getParameter("fix") != null) {
						 %>
							<input type="hidden" name="fix_mode"> <input type="submit"
							value="更新" name="kousin"> <%}%>
					</span> 
					<span class="margin_r"> 
							
						<%
						//修正のときだけ削除ボタンを表示
						 if (request.getParameter("fix") != null) {
						 %>
							<input type="submit" value="削除" name="sakujo"> <%}%>
					</span>
					<span class="margin_r"> 
							
						<%
						//修正じゃない（登録）ときだけ登録ボタンを表示
						 if (request.getParameter("fix") == null) {
						 %>
							<input type="submit" value="登録" name="touroku"> <%}%>
					</span>
				</div>
			</form>
		</div>
	</body>
</html>