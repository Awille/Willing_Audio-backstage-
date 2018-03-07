<%--
  Created by IntelliJ IDEA.
  User: wille
  Date: 2017/12/29
  Time: 20:16
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.io.BufferedReader" %>
<%@ include file="DatabaseAccess.jsp" %>

<%
    request.setCharacterEncoding("utf-8");
%>

<%
    System.out.println("some one come");
    if(request.getMethod().equalsIgnoreCase("post")){
        Gson gson=new Gson();
        System.out.println(request.getParameter("intent"));

        //获得post的数据
        StringBuffer stringBuffer=new StringBuffer();
        String line=null;

        try {
            BufferedReader bufferedReader=request.getReader();
            while ((line=bufferedReader.readLine())!=null){
                stringBuffer.append(line);
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }

        String data=stringBuffer.toString();

        String intent=request.getParameter("intent");

        System.out.println("intent is : "+intent);
        System.out.println("data is : "+data);

        Json.User user=null;
        Json.Song song=null;
        Json.Songs songs=null;
        Json.SongList songList=null;
        Json.SongLists songLists=null;
        Json.userSongLists userSongLists=null;

        Json.Comment comment=null;
        Json.Comments comments=null;
        Json.list_song list_song=null;
        if(intent!=null &&data!=null){
            DatabaseAccess.establishConnection();
            switch (intent){
                case "register"://注册新用户
                    user=gson.fromJson(data,Json.User.class);
                    String account=DatabaseAccess.addUser(user.account,user.nickname,user.password);
                    if(account==null){
                        out.print(gson.toJson(new Json.Message("error","This account has been occupied! ,null")));
                    }
                    else{
                        out.print(gson.toJson(new Json.Message()));
                    }
                    break;

                case "modify_user"://修改用户
                    user =gson.fromJson(data,Json.User.class);
                    Boolean ok=DatabaseAccess.modifyUser(user);
                    if(ok==false){
                        out.print(gson.toJson(new Json.Message("error","change fail")));
                    }
                    else {
                        out.print(gson.toJson(new Json.Message()));
                    }
                    break;

                case "sign_in"://登陆用户
                    user =gson.fromJson(data,Json.User.class);
                    Json.User real_user=DatabaseAccess.getUserByAccount(user.account);
                    System.out.println("user pass: "+real_user.password);
                    System.out.println("submit pass: "+user.password);
                    if(real_user!=null){
                        System.out.println("here");
                        if(real_user.password.equals(user.password)){
                            System.out.println("here1");
                            out.print(gson.toJson(new Json.Message("success","login success",real_user)));
                        }
                        else{
                            out.print(gson.toJson(new Json.Message("error","password mismatch")));
                        }
                    }
                    else{
                        out.print(gson.toJson(new Json.Message("error", "this user not exits")));
                    }
                    break;

                case "get_song"://传入id获取歌曲
                    song=gson.fromJson(data,Json.Song.class);
//                    Long testid=Long.parseLong(song.songId);
//                    System.out.println(testid);
                    System.out.println(song.songId);
                    Json.Song get_song=DatabaseAccess.getSongBySongId(song.songId);
                    System.out.println("okokkoko");
                    if(get_song==null){
                        out.print(gson.toJson(new Json.Message("error","this song not exit")));
                        System.out.print("errrorrr");
                    }
                    else{
                        System.out.println("okokkoko");
                        out.print(gson.toJson(new Json.Message("success","get this song successfully",get_song)));
                    }
                    break;

                case "get_list_by_id"://根据id获取歌单
                    songList=gson.fromJson(data,Json.SongList.class);
                    Json.SongList get_songList=DatabaseAccess.getSongListByListId(songList.listId);
                    if(get_songList==null){
                        out.print(gson.toJson(new Json.Message("error","this songList not exit")));
                    }
                    else{
                        out.print(gson.toJson(new Json.Message("success","get successfully",get_songList)));
                    }
                    break;

                case "get_list_by_account": //根据用户获取歌单
                    userSongLists=gson.fromJson(data,Json.userSongLists.class);
                    Json.userSongLists get_userSongLists=DatabaseAccess.getUserSongListsByAccount(userSongLists.account);
                    if(get_userSongLists==null){
                        out.print(gson.toJson(new Json.Message("error","get failed")));

                        System.out.println("faillllllll");
                    }
                    else {
                        System.out.println("successsssss");
                        out.print(gson.toJson(new Json.Message("success","get successfully",get_userSongLists)));
                    }
                    break;

                case "add_comment"://增加评论
                    comment=gson.fromJson(data,Json.Comment.class);
                    Long get_commentId=DatabaseAccess.diliverComment(comment);
                    if(get_commentId!=null){
                        out.print(gson.toJson(new Json.Message()));
                    }
                    else {
                        out.print(gson.toJson(new Json.Message("error","add comment failed")));
                    }
                    break;

                case "get_song_comments"://获得歌曲评论
                    comment=gson.fromJson(data,Json.Comment.class);
                    System.out.println("get_song id is  :"+comment.songId);
                    comments=DatabaseAccess.getCommentsBySongId(comment.songId);
                    if(comments==null){
                        out.print(gson.toJson(new Json.Message("error","get failed")));
                    }
                    else {
                        out.print(gson.toJson(new Json.Message("success","get success",comments)));
                    }
                    break;

                case "add_song_to_list": //往歌单里面里面添加歌曲
                    list_song=gson.fromJson(data,Json.list_song.class);
                    System.out.println("listIDDDD"+list_song.listId);
                    System.out.println("songIDDDD"+list_song.songId);
                    Long list_song_id=DatabaseAccess.addSongToList(list_song.listId,list_song.songId);
                    if(list_song_id!=null){
                        out.print(gson.toJson(new Json.Message()));System.out.println("addddddsuccess");
                    }
                    else{
                        out.print(gson.toJson(new Json.Message("error","error")));
                    }
                    break;

                case "get_user_ByAccount":
                    user=gson.fromJson(data,Json.User.class);
                    Json.User get_user=DatabaseAccess.getUserByAccount(user.account);
                    if(get_user!=null){
                        out.print(gson.toJson(new Json.Message("sucess","ok",get_user)));
                    }
                    else{
                        out.print(gson.toJson(new Json.Message("error","error")));
                    }
                    break;
                case "create_new_songlist"://根据listname往总歌单里面添加新歌单
                    Json.NewSonglist newSonglist=gson.fromJson(data,Json.NewSonglist.class);
                    Long Song_List_id=DatabaseAccess.userCreateSongList(newSonglist.account,newSonglist.listname);
                    if(Song_List_id==null){
                        out.print(gson.toJson(new Json.Message("error","This account has been occupied! ,null")));
                    }
                    else{
                        out.print(gson.toJson(new Json.Message()));
                    }
                    break;


                case "delete_songlist"://根据listID删除歌单
                    Json.DeleteSonglist deletesongList=gson.fromJson(data,Json.DeleteSonglist.class);
                    Long deletesongListID=DatabaseAccess.deleteSongList(deletesongList.listId);
                    if(deletesongListID==null){
                        out.print(gson.toJson(new Json.Message("error","This account has been occupied! ,null")));
                    }
                    else{
                        out.print(gson.toJson(new Json.Message()));
                    }
                    break;

                case "get_all_users"://获取所有用户信息
                    //Json.Users alluser=gson.fromJson(data,Json.Users.class);
                    Json.Users alluser=DatabaseAccess.getAllUser();
                    if(alluser==null){
                        out.print(gson.toJson(new Json.Message("error","This account has been occupied! ,null")));
                    }
                    else{
                        System.out.println("alluser"+alluser.userList.size());
                        out.print(gson.toJson(new Json.Message("success","get success",alluser)));
                    }
                    break;

                case "get_random_list": //随机获取6个获取歌单
                    System.out.println("get_random_list");
                    Json.SongLists get_randomSongLists=DatabaseAccess.getRandomSongList();
                    if(get_randomSongLists==null){
                        out.print(gson.toJson(new Json.Message("error","get failed")));
                        System.out.println("faillllllll");
                    }
                    else {
                        System.out.println("successsssss");
                        System.out.println("randomsize="+get_randomSongLists.songLists.size());
                        out.print(gson.toJson(new Json.Message("success","get successfully",get_randomSongLists)));
                    }
                    break;

                case "get_random_song": //随机获取4个获取歌曲
                    System.out.println("get_random_song");
                    Json.Songs get_randomSongs=DatabaseAccess.getRandomSongs();
                    if(get_randomSongs==null){
                        out.print(gson.toJson(new Json.Message("error","get failed")));
                        System.out.println("faillllllll");
                    }
                    else {
                        System.out.println("successsssss");
                        System.out.println("randomsize="+get_randomSongs.songs.size());
                        out.print(gson.toJson(new Json.Message("success","get successfully",get_randomSongs)));
                    }
                    break;


                case "collect_list":
                    Json.user_list tmp=gson.fromJson(data,Json.user_list.class);
                    if(tmp!=null){
                        System.out.println("collect list here"+tmp.account+" "+tmp.listId);
                        Long su=DatabaseAccess.UserCollectSongList(tmp.account,tmp.listId);
                        out.print(gson.toJson(new Json.Message()));
                    }

                    break;

                default:
                    break;
            }
            DatabaseAccess.closeConnection();
        }


    }
%>
