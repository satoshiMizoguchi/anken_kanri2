/*
詳細画面(shosai2.jsp)での更新・登録処理を行うサーブレットです。

処理が終わり問題が無ければ一覧画面(itiran2.jsp)へ、
問題があればエラー画面(fusei.jsp)へ遷移します。
*/

package anken_kanri2;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class Edit
 */
@WebServlet("/Edit2")
public class Edit2 extends HttpServlet {
	private static final long serialVersionUID = 1L;
	Connection con = null;
	Statement stmt = null;
	ResultSet rs = null;
	RequestDispatcher rd = null;
	//DB接続用定数
    String DATABASE_NAME = "portfolio";
    String PROPATIES = "?characterEncoding=UTF-8";
    String URL = "jdbc:mySQL://localhost:4000/" + DATABASE_NAME+PROPATIES;
    //DB接続用・ユーザ定数
    String USER = "root";
    String PASS = "aiueo300";
	String SQL = null;
	String SQL2 = null;

	public Edit2() {
		super();
	}

	//入力された納品予定日が日付として適切かチェックする
	public static boolean checkDate(String strDate) {
		if (strDate.equals("")) {
			return true;
		}
		if (strDate.length() != 10) {
			return false;
		}

		if (strDate.contains("-")) {
			strDate = strDate.replace('-', '/');
		}

		DateFormat format = DateFormat.getDateInstance();
		format.setLenient(false);
		try {
			format.parse(strDate);
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	//入力された予定工数が数値として適切かチェックする
	public static boolean checkKousuu(String strKousuu) {
		boolean isNumeric = true;
		for (int i = 0; i < strKousuu.length(); i++) {
			if (!Character.isDigit(strKousuu.charAt(i))) {
				if (strKousuu.charAt(i) == '.') {
					continue;
				}
				isNumeric = false;
			}
		}
		return isNumeric;
	}
	
	//入力された予定工数がデータベースの型decimal(8,2)を満たすかチェックする
	public static boolean checkWithin8(String strKousuu) {
		int cnt = 0;
		if(strKousuu.contains(".")) {
			for(int i = 0; i < strKousuu.length(); i++) {
				if(strKousuu.charAt(i) == '.') {
					break;
				}
				cnt++;
			}
			
			if(cnt > 6) {
				return false;
			}
			return true;
		}else {
			if(strKousuu.length() > 6) {
				return false;
			}
				return true;
		}
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String anken_id_shosai = request.getParameter("anken_id_shosai");
		String anken_name_shosai = request.getParameter("anken_name_shosai");
		String status_name_shosai = request.getParameter("status_name_shosai");
		String priority_shosai = request.getParameter("priority_shosai");
		String anken_date_shosai = request.getParameter("anken_date_shosai");
		String anken_kousuu_shosai = request.getParameter("anken_kousuu_shosai");
		String tantou_name_shosai = request.getParameter("tantou_name_shosai");
		String bikou_shosai = request.getParameter("bikou_shosai");
		String status_id_shosai = null;
		String tantou_id_shosai = null;
		boolean flag = true;

		HttpSession session = request.getSession();
		
		//Edit2からshosai2へ遷移した際エラーのセッションを使用するためここでremove
		session.removeAttribute("numberEx");
		session.removeAttribute("parseEx");
		session.removeAttribute("nullEx");
		session.removeAttribute("kousuu_over");
		session.removeAttribute("bikou_over");
		session.removeAttribute("anken_shosai_over");
		
		
		//詳細画面の各種入力値をセット
		session.setAttribute("anken_name_shosai", anken_name_shosai);
		session.setAttribute("status_name_shosai", status_name_shosai);	
		session.setAttribute("priority_shosai", priority_shosai);
		session.setAttribute("anken_date_shosai", anken_date_shosai);
		session.setAttribute("anken_kousuu_shosai", anken_kousuu_shosai);
		session.setAttribute("tantou_name_shosai", tantou_name_shosai);
		session.setAttribute("bikou_shosai", bikou_shosai);
		
		//詳細画面での各種入力値のエラーチェック
		if(checkKousuu(anken_kousuu_shosai)) {
			if(!(checkWithin8(anken_kousuu_shosai))) {
				session.setAttribute("kousuu_over", "予定工数が8桁を超えています");
			}
		}
		else{
			session.setAttribute("numberEx", "予定工数が数値ではありません");
		}

		if (checkDate(anken_date_shosai) == false) {
			session.setAttribute("parseEx", "納品予定日が日付ではありません");
		}
		
		if(bikou_shosai.length() > 256) {
			session.setAttribute("bikou_over", "備考は256字以内で入力してください");
		}
		
		if(anken_name_shosai.length() > 100) {
			session.setAttribute("anken_shosai_over", "案件名は100字以内で入力してください");
		}
		

		try {
			Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}

		try {
			con = DriverManager.getConnection(URL, USER, PASS);
			stmt = con.createStatement();
			
			//詳細画面で「登録」ボタンが押されたとき
			if (request.getParameter("touroku") != null) {
				if (status_name_shosai.equals("選択してください")) {
					status_name_shosai = "";
				}
				if (anken_id_shosai.equals("") || anken_name_shosai.equals("") || status_name_shosai.equals("")) {
					session.setAttribute("nullEx", "案件ID,案件名,ステータスは必ず入力が必要です");
				}
				//何らかの条件エラーがあるとエラー画面へ遷移
				if (session.getAttribute("numberEx") != null || session.getAttribute("parseEx") != null
						|| session.getAttribute("nullEx") != null || session.getAttribute("bikou_over") != null
						|| session.getAttribute("anken_shosai_over") != null || session.getAttribute("kousuu_over") != null) {
					flag = false;
					rd = request.getRequestDispatcher("/fusei.jsp");
					rd.forward(request, response);
				}
				SQL = "SELECT * FROM status_table WHERE status_name = '";
				SQL += status_name_shosai + "'";
				rs = stmt.executeQuery(SQL);
				while (rs.next()) {
					status_id_shosai = rs.getString("status_id");
				}

				SQL = "INSERT INTO project_table(";
				SQL += "item_id," ;
				SQL += "project_title," ;
				SQL += "status_id,";
				SQL += "priority,";
				SQL += "delivery_date,";
				SQL += "man_hour," ;
				SQL += "contact_id,";
				SQL += "remarks) ";
				SQL += "VALUES(";
				SQL += anken_id_shosai + ",'";
				SQL += anken_name_shosai + "',";
				SQL += status_id_shosai + ",";;
				
				if (priority_shosai.equals("選択してください")) {
					SQL += null;
				} else {
					SQL += priority_shosai;
				}
				if (anken_date_shosai.equals("")) {
					SQL += "," + null + ",";
				} else {
					SQL += ", '" + anken_date_shosai + "', ";
				}

				if (anken_kousuu_shosai.equals("")) {
					SQL += null + ",";
				} else {
					SQL += anken_kousuu_shosai + ",";
				}
				
				if (tantou_name_shosai.equals("選択してください")) {
					SQL += null;
				} else {
					SQL2 = "SELECT * FROM Staff_master ";
					SQL2 += "WHERE last_name + first_name = '";		
					SQL2 += tantou_name_shosai + "'";
					rs = stmt.executeQuery(SQL2);
					while (rs.next()) {
						tantou_id_shosai = rs.getString("staff_id");
					}
					SQL += tantou_id_shosai;
				}
				SQL += ", '" + bikou_shosai + "')";
				
			//詳細画面で「削除」ボタンが押されたとき		
			} else if (request.getParameter("sakujo") != null) {
				if (!(anken_id_shosai.equals(""))) {
					SQL = "DELETE FROM project_table ";
					SQL += "WHERE item_id = ";
					SQL += anken_id_shosai;
				} else {
					session.setAttribute("nullEx", "nullEx");
					rd = request.getRequestDispatcher("/fusei.jsp");
					rd.forward(request, response);
				}

			//詳細画面で「更新」ボタンが押されたとき	
			} else if (request.getParameter("kousin") != null) {
				if (status_name_shosai.equals("選択してください")) {
					status_name_shosai = "";
				}
				if (anken_id_shosai.equals("") || anken_name_shosai.equals("") || status_name_shosai.equals("")) {
					session.setAttribute("nullEx", "案件ID,案件名,ステータスは必ず入力が必要です");
				}
				if (session.getAttribute("numberEx") != null || session.getAttribute("parseEx") != null
						|| session.getAttribute("nullEx") != null || session.getAttribute("bikou_over") != null
						|| session.getAttribute("anken_shosai_over") != null || session.getAttribute("kousuu_over") != null) {
					flag = false;
					rd = request.getRequestDispatcher("/fusei.jsp");
					rd.forward(request, response);
				}
				
				
				
				SQL = "SELECT * FROM status_table ";
				SQL += "WHERE status_name = '";
				SQL += status_name_shosai + "'";
				rs = stmt.executeQuery(SQL);
				while (rs.next()) {
					status_id_shosai = rs.getString("status_id");
				}
				 
				SQL = "UPDATE project_table ";
				SQL += "SET project_title = '";
				SQL += anken_name_shosai + "',";
					
				
				SQL += "status_id = " + status_id_shosai + ",";
				if (!(priority_shosai.equals("選択してください"))) {
					SQL += "priority = " + priority_shosai + ",";
				} else {
					SQL += "priority = " + null + ",";
				}
				if (!(anken_date_shosai.equals(""))) {
					SQL += "delivery_date = '" + anken_date_shosai + "',";
				} else {
					SQL += "delivery_date = " + null + ",";
				}
				if (!(anken_kousuu_shosai.equals(""))) {
					SQL += "man_hour = " + anken_kousuu_shosai + ",";
				} else {
					SQL += "man_hour = " + null + ",";
				}
				if (!(tantou_name_shosai.equals("選択してください"))) {
					SQL2 = "SELECT * FROM Staff_master ";
					SQL2 += "WHERE last_name + first_name = '";
					SQL2 += tantou_name_shosai + "'";
					rs = stmt.executeQuery(SQL2);
					while (rs.next()) {
						tantou_id_shosai = rs.getString("staff_id");
					}
					
					SQL += "contact_id = '" + tantou_id_shosai + "',";
				} else {
					SQL += "contact_id = " + null + ",";
				}
				if (!(bikou_shosai.equals(""))) {
					SQL += "remarks = '" + bikou_shosai + "'";
				} else {
					SQL += "remarks = " + null;
				}
				SQL += " WHERE item_id = " + anken_id_shosai;

			}
			
			if(flag){
				stmt.executeUpdate(SQL);
				rd = request.getRequestDispatcher("/itiran2.jsp");
				rd.forward(request, response);
			}
			rs.close();
			con.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e2) {
			e2.printStackTrace();
		}			

	}

}
