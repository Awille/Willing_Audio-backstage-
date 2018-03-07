<%--
  Created by IntelliJ IDEA.
  User: wille
  Date: 2017/12/29
  Time: 0:31
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="Json.jsp"%>

<%
    request.setCharacterEncoding("utf-8");
%>

<%!
    static class DatabaseAccess{
        private static String connectString="jdbc:mysql://localhost:3306/wille"
                +"?autoReconnect=true&useUnicode=true"
                +"&characterEncoding=UTF-8&useSSL=false";
        private static Connection connection;

        private static SimpleDateFormat simpleDateFormat=new SimpleDateFormat("yyyy-MM-dd:mm:ss");

        public static String HtmlFilter(String input) {
            return input.replaceAll("&", "&amp;")
                    .replaceAll("<", "&lt;")
                    .replaceAll(">", "&gt;")
                    .replaceAll("\"", "&quot;")
                    .replaceAll("'", "&apos;")
                    .replaceAll(" ", "&nbsp;")
                    .replaceAll("\n", "<br>");
        }

        //建立数据库连接
        public static Boolean establishConnection(){
            try{
                Class.forName("com.mysql.jdbc.Driver");
                connection=DriverManager.getConnection(connectString,"root","");
                return true;
            }catch (Exception e){
                e.printStackTrace();
            }
            return false;
        }
        //关闭数据库连接
        public static Boolean closeConnection(){
            try{
                connection.close();
                return true;
            }catch (Exception e){
                e.printStackTrace();
            }
            return false;
        }

        //添加用户
        public static String addUser(String account, String nickname,String password){
            if(account==null||nickname==null ||password==null) return null;
            if(account.equals("")) return null;

            account=HtmlFilter(account);
            nickname=HtmlFilter(nickname);
            password=HtmlFilter(password);

            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("INSERT INTO user (account,nickname,password) VALUES (?,?,?)",
                                Statement.RETURN_GENERATED_KEYS);
                preparedStatement.setString(1,account);
                preparedStatement.setString(2,nickname);
                preparedStatement.setString(3,password);

                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    return account;
//                    System.out.println("okkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
//                    ResultSet resultSet=preparedStatement.getGeneratedKeys();
//                    if(resultSet.next()){
//                        System.out.println("sadasdasadasds");
//                        String r_account=resultSet.getString("account");
//                        System.out.println("sadasda"+r_account);
//                        resultSet.close();
//                        preparedStatement.close();
//                        return  r_account;
//                    }
//                    else{
//                        System.out.println("eeeeeeeeeeeeeeee");
//                        resultSet.close();
//                        preparedStatement.close();
//                    }
                }
                else{
                    preparedStatement.close();
                }
            }catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }

        //修改用户信息 不包括头像
        public static Boolean modifyUser(Json.User user){
            if(user==null) return false;
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("UPDATE user SET nickname=?, password=?,favourite_singer=?,favourite_song=?,sex=?,signature=? WHERE account=?");
                preparedStatement.setString(1,user.nickname);
                preparedStatement.setString(2,user.password);
                preparedStatement.setString(3,user.favourite_singer);
                preparedStatement.setString(4,user.favourite_song);
                preparedStatement.setString(5,user.sex);
                preparedStatement.setString(6,user.signature);
                preparedStatement.setString(7,user.account);
                int affectedRows = preparedStatement.executeUpdate();
                if(affectedRows > 0) return true;
                else return false;
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return false;
        }

        //修改用户头像
        public static Boolean modifyAvator(Json.User user){
            System.out.println("fererererr");
            if(user==null) return false;
            System.out.println(user.account);
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("UPDATE user SET avator=? WHERE account=?");
                preparedStatement.setString(1,user.avator);
                preparedStatement.setString(2,user.account);
                int affectedRows = preparedStatement.executeUpdate();
                System.out.println("是否已经修改:"+affectedRows);
                if(affectedRows > 0) return true;
                else return false;
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return false;
        }

        //修改歌曲头像
        public static Boolean modifySongAvator(Json.Song song){
            if(song==null) return false;
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("UPDATE song SET songAvator=? WHERE songId=?");
                preparedStatement.setString(1,song.songAvator);
                preparedStatement.setLong(2,song.songId);
                int affectedRows = preparedStatement.executeUpdate();
                if(affectedRows > 0) return true;
                else return false;
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return false;
        }

        //修改歌单头像
        public static Boolean modifyListAvator(Json.SongList songList){
            if(songList==null) return false;
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("UPDATE song_list SET listAvator=? WHERE listId=?");
                preparedStatement.setString(1,songList.listAvator);
                preparedStatement.setLong(2,songList.listId);
                int affectedRows = preparedStatement.executeUpdate();
                if(affectedRows > 0) return true;
                else return false;
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return false;
        }

        //从用户acount得到昵称
        public static String getNicknameByAccount(String account){
            if(account=="") return null;
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT nickname FROM user WHERE account=?");
                preparedStatement.setString(1,account);
                ResultSet resultSet=preparedStatement.executeQuery();
                if(resultSet.next()){
                    String r_account=resultSet.getString(1);
                    resultSet.close();
                    preparedStatement.close();
                    return  r_account;
                }
                else {
                    resultSet.close();
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }


        //用account获取用户消息
        public static Json.User getUserByAccount(String account){
            if(account==null) return null;
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM user WHERE account=?");
                preparedStatement.setString(1,account);

                ResultSet resultSet=preparedStatement.executeQuery();
                if (resultSet.next()){
                    Json.User user=new Json.User(resultSet.getString("account"),
                            resultSet.getString("nickname"),
                            resultSet.getString("password"),
                            resultSet.getString("avator"),
                            resultSet.getString("favourite_singer"),
                            resultSet.getString("favourite_song"),
                            resultSet.getString("signature"),
                            resultSet.getString("sex"));
                    resultSet.close();
                    preparedStatement.close();
                    return user;
                }
                else {
                    resultSet.close();
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }


        //根据songid获得歌曲
        public static Json.Song getSongBySongId(Long sid){
            if(sid==null) return null;
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM song WHERE songId = ?");
                preparedStatement.setLong(1,sid);
                ResultSet resultSet=preparedStatement.executeQuery();
                if (resultSet.next()){
                    Json.Song song=new Json.Song(resultSet.getLong("songId"),
                            resultSet.getString("songName"),
                            resultSet.getString("singer"),
                            resultSet.getString("type"),
                            resultSet.getLong("popularity"),
                            resultSet.getString("songAvator"),
                            resultSet.getString("URL"),
                            resultSet.getString("lrc"));
                    resultSet.close();
                    preparedStatement.close();
                    return song;
                }
                else {
                    resultSet.close();
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }

        public static Json.SongList getSongListByListId(Long lid){
            if(lid==null) return null;
            Json.Songs songs=new Json.Songs();
            //首先获取歌曲列表
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT songId FROM list WHERE listId=?");
                preparedStatement.setLong(1,lid);
                ResultSet resultSet=preparedStatement.executeQuery();
                while (resultSet.next()){
                    Long songid=resultSet.getLong("songId");
                    Json.Song song=getSongBySongId(songid);
                    songs.songs.add(song);
                }
                resultSet.close();
                preparedStatement.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }
            //接着获取歌单信息
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM song_list WHERE listID=?");
                preparedStatement.setLong(1,lid);
                ResultSet resultSet=preparedStatement.executeQuery();
                if(resultSet.next()){
                    Json.SongList songList=new Json.SongList(resultSet.getLong("listID"),
                            resultSet.getString("listName"),
                            resultSet.getString("type"),
                            resultSet.getString("listAvator"),
                            songs);
                    resultSet.close();
                    preparedStatement.close();
                    return  songList;
                }
                else{
                    resultSet.close();
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }

        public static Json.userSongLists getUserSongListsByAccount(String account){
            if(account==null) return null;

            Json.userSongLists userSongLists=new Json.userSongLists();
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT listId, isCreate FROM tlist WHERE account=?");
                preparedStatement.setString(1,account);
                ResultSet resultSet=preparedStatement.executeQuery();
                Json.SongLists mycreate=new Json.SongLists();
                Json.SongLists mycollect=new Json.SongLists();


                while (resultSet.next()){
                    System.out.println("t_list table success!");
                    if(resultSet.getLong("isCreate")==1){
                        System.out.println("iscreate success!");
                        System.out.println(resultSet.getLong("listId"));
                        mycreate.songLists.add(getSongListByListId(resultSet.getLong("listId")));
                    }
                    else{
                        mycollect.songLists.add(getSongListByListId(resultSet.getLong("listId")));
                    }
                }
                userSongLists.account=account;
                userSongLists.mycreate=mycreate;
                userSongLists.mycollect=mycollect;
                resultSet.close();
                preparedStatement.close();

                return userSongLists;


            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }


        //用户收藏歌单
        public static Long UserCollectSongList(String account,Long listId){
            if(account==null||listId==null){
                return null;
            }
            try {

                PreparedStatement preparedStatement1=
                        connection.prepareStatement("SELECT listId, isCreate FROM tlist WHERE account=?");
                preparedStatement1.setString(1,account);
                ResultSet resultSet1=preparedStatement1.executeQuery();
                while (resultSet1.next()){
                    if(resultSet1.getLong("listId")==listId){
                        resultSet1.close();
                        preparedStatement1.close();
                        return listId;
                    }
                }




                PreparedStatement preparedStatement=
                        connection.prepareStatement("INSERT INTO tlist (account, listId, isCreate) VALUES (?,?,?)");
                preparedStatement.setString(1,account);
                preparedStatement.setLong(2,listId);
                preparedStatement.setLong(3,0);
                int affectedRows=preparedStatement.executeUpdate();
                if(affectedRows>0){
//                    ResultSet resultSet=preparedStatement.getGeneratedKeys();
//                    if(resultSet.next()){
//                        Long list_song_id=resultSet.getLong(1);
//                        resultSet.close();
//                        preparedStatement.close();
//                        return list_song_id;
//                    }
//                    else {
//                        resultSet.close();
//                        preparedStatement.close();
//                    }
                    preparedStatement.close();
                    return Long.valueOf(1);
                }
                else{
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }

        //用户创建歌单
        public static Long userCreateSongList(String account,String listname){
            if(listname==null||account==null){
                return null;
            }
            System.out.println("userCreateSongList");
            System.out.println("account:"+account+"  listname"+listname);
            Long Song_List_id = null;
            try{
                PreparedStatement preparedStatement=
                        connection.prepareStatement("INSERT INTO song_list (listName) VALUES (?)",Statement.RETURN_GENERATED_KEYS);
                preparedStatement.setString(1,listname);
                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    ResultSet resultSet=preparedStatement.getGeneratedKeys();
                    if(resultSet.next()){
                        Song_List_id=resultSet.getLong(1);
                        resultSet.close();
                        preparedStatement.close();
                    }
                    else {
                        resultSet.close();
                        preparedStatement.close();
                    }
                }
                else{
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }

            if(Song_List_id!=null){
                try {
                    PreparedStatement preparedStatement=
                            connection.prepareStatement("INSERT INTO tlist (account, listId, isCreate) VALUES (?,?,?)");
                    preparedStatement.setString(1,account);
                    preparedStatement.setLong(2,Song_List_id);
                    preparedStatement.setLong(3,1);

                    preparedStatement.executeUpdate();

                    preparedStatement.close();
                }
                catch (Exception e){
                    e.printStackTrace();
                }
            }
            return Song_List_id;
        }
        //根据listname从tlist和song_lists中删除歌单
        public static Long deleteSongList(Long listId){
            System.out.println("delete "+listId);
            Long deletesongListID=null;
            if(listId==null) return null;
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("DELETE FROM tlist WHERE listId="+listId);
                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    deletesongListID=Long.valueOf(100);
                }
                else {
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("DELETE FROM song_list WHERE listID="+listId);
                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    deletesongListID=Long.valueOf(200);
                }
                else {
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return deletesongListID;
        }

        //根据listid往歌单里面添加歌曲
        public static Long addSongToList(Long listid, Long songId){
            if(listid==null||songId==null) return null;
            try {

                PreparedStatement preparedStatement1=
                        connection.prepareStatement("SELECT songId FROM list WHERE listId=?");
                preparedStatement1.setLong(1,listid);
                ResultSet resultSet1=preparedStatement1.executeQuery();
                while (resultSet1.next()){
                    Long songid=resultSet1.getLong("songId");
                    if(songid==songId) return null;
                }
                resultSet1.close();
                preparedStatement1.close();
                PreparedStatement preparedStatement= connection.prepareStatement("INSERT INTO list (listId,songId) VALUES (?,?)");
                preparedStatement.setLong(1,listid);
                preparedStatement.setLong(2,songId);
                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    return Long.valueOf(1);
                }
                else {
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }


        //根据songid获取评论
        public static Json.Comments getCommentsBySongId(Long songid){
            if(songid==null){
                return null;
            }
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM comment WHERE songId=?");
                preparedStatement.setLong(1,songid);

                System.out.println("here"+songid);

                ResultSet resultSet=preparedStatement.executeQuery();
                Json.Comments comments=new Json.Comments();
                while (resultSet.next()){
                    Json.Comment comment=new Json.Comment(resultSet.getLong("commentId"),
                            resultSet.getString("account"),
                            resultSet.getString("content"),
                            resultSet.getLong("songId"),
                            resultSet.getString("time"),
                            resultSet.getLong("rcommentId"),
                            resultSet.getLong("like"));
                    comments.comments.add(comment);
                }
                resultSet.close();
                preparedStatement.close();
                return comments;

            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }

        //发表评论
        public static Long diliverComment(Json.Comment comment){
            if(comment==null) return null;
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("INSERT INTO comment (account,content,songId) VALUES (?,?,?)");
                preparedStatement.setString(1,comment.account);
                preparedStatement.setString(2,comment.content);
                preparedStatement.setLong(3,comment.songId);

                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    ResultSet resultSet=preparedStatement.getGeneratedKeys();
                    if(resultSet.next()){
                        Long comment_id=resultSet.getLong(1);
                        resultSet.close();
                        preparedStatement.close();
                        return  comment_id;
                    }
                    else {
                        resultSet.close();
                        preparedStatement.close();
                    }
                }
                else{
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }


        //回复
        public static Long recoverComment(Json.Comment comment){
            if(comment==null) return null;
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("INSERT INTO comment (account,content,songId,rCommentId) VALUES (?,?,?,?)");
                preparedStatement.setString(1,comment.account);
                preparedStatement.setString(2,comment.content);
                preparedStatement.setLong(3,comment.songId);
                preparedStatement.setLong(4,comment.rCommentId);

                int affectRows=preparedStatement.executeUpdate();
                if(affectRows>0){
                    ResultSet resultSet=preparedStatement.getGeneratedKeys();
                    if(resultSet.next()){
                        Long comment_id=resultSet.getLong(1);
                        resultSet.close();
                        preparedStatement.close();
                        return  comment_id;
                    }
                    else {
                        resultSet.close();
                        preparedStatement.close();
                    }
                }
                else{
                    preparedStatement.close();
                }
            }
            catch (Exception e){
                e.printStackTrace();
            }
            return null;
        }

        //获取所有用户消息
        public static Json.Users getAllUser(){
            System.out.println("getAllusers");
            Json.Users users=new Json.Users();
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM user ");
                ResultSet resultSet=preparedStatement.executeQuery();
                while(resultSet.next()){
                    //System.out.println(resultSet.getString("nickname"));
                    Json.User user=new Json.User(
                            resultSet.getString("account"),
                            resultSet.getString("nickname"),
                            resultSet.getString("password"),
                            resultSet.getString("avator"),
                            resultSet.getString("favourite_singer"),
                            resultSet.getString("favourite_song"),
                            resultSet.getString("signature"),
                            resultSet.getString("sex"));
                    users.userList.add(user);
                }
                resultSet.close();
                preparedStatement.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }
            //System.out.println(users.userList.size());
            return users;
        }




        //获取6个随机歌单
        public static Json.SongLists getRandomSongList(){

            Json.SongLists songLists=new Json.SongLists();
            Json.SongLists temsongLists=new Json.SongLists();
            //首先获取歌曲列表
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM song_list");
                ResultSet resultSet=preparedStatement.executeQuery();
                while (resultSet.next()){
                    Json.SongList songList=new Json.SongList();
                    songList.listId=resultSet.getLong("listId");
                    songList.listName=resultSet.getString("listName");
                    songList.type=resultSet.getString("type");
                    songList.listAvator=resultSet.getString("listAvator");
                    temsongLists.songLists.add(songList);
                }

                System.out.println("temsize="+temsongLists.songLists.size());
                for(int i=0;i<6;i++){
                    Random rand =new Random();
                    int j=0;
                    j=rand.nextInt(temsongLists.songLists.size());
                    songLists.songLists.add(temsongLists.songLists.get(j));
                    temsongLists.songLists.remove(j);
                }
                System.out.println("randomsonglistsize="+songLists.songLists.size());

                resultSet.close();
                preparedStatement.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }

            return songLists;
        }
        //获取4首随机歌曲
        public static Json.Songs getRandomSongs(){

            Json.Songs songs=new Json.Songs();
            Json.Songs temsongs=new Json.Songs();
            //首先获取歌曲列表
            try {
                PreparedStatement preparedStatement=
                        connection.prepareStatement("SELECT * FROM song");
                ResultSet resultSet=preparedStatement.executeQuery();
                while (resultSet.next()){
                    Json.Song song=new Json.Song();
                    song.songId=resultSet.getLong("songId");
                    song.popularity=resultSet.getLong("popularity");
                    song.songName=resultSet.getString("songName");
                    song.singer=resultSet.getString("singer");
                    song.type=resultSet.getString("type");
                    song.songAvator=resultSet.getString("songAvator");
                    song.URL=resultSet.getString("URL");
                    song.lrc=resultSet.getString("lrc");

                    temsongs.songs.add(song);
                }

                System.out.println("temsongsize="+temsongs.songs.size());
                for(int i=0;i<4;i++){
                    Random rand =new Random();
                    int j=0;
                    j=rand.nextInt(temsongs.songs.size());
                    songs.songs.add(temsongs.songs.get(j));
                    temsongs.songs.remove(j);
                }
                System.out.println("randomsongsize="+songs.songs.size());

                resultSet.close();
                preparedStatement.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }

            return songs;
        }
































    }
%>