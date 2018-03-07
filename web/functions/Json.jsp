<%--
  Created by IntelliJ IDEA.
  User: wille
  Date: 2017/12/28
  Time: 22:54
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.security.MessageDigest, java.sql.*" %>

<%
    request.setCharacterEncoding("utf-8");
%>

<%!
    static class Json{
        //消息模板类
        static class Message{
            public String state;
            public String message;
            public Object data;

            public Message(){
                state="success";
                message="Operating Normally";
            }

            public Message(String state,String message){
                this.state=state;
                this.message=message;
            }

            public Message(String state, String message, Object data) {
                this.state = state;
                this.message = message;
                this.data = data;
            }
        }

        static class User{ //用户模板类
            public String account;
            public String nickname;
            public String password;
            public String avator;
            public String favourite_singer;
            public String favourite_song;
            public String signature;
            public String sex;

            public User(){
                account="";
                nickname="";
                password="";
                avator="newuser.jpg";
            }

            public User(String account,String nickname, String password,String favourite_singer,String favourite_song,String signature,String sex){
                this.account=account;
                this.nickname=nickname;
                this.password=password;
                this.favourite_singer=favourite_singer;
                this.favourite_song=favourite_song;
                this.signature=signature;
                this.sex=sex;
                avator="newuser.jpg";
            }

            public User(String account,String nickname, String password,String avator,String favourite_singer,String favourite_song,String signature,String sex){
                this.account=account;
                this.nickname=nickname;
                this.password=password;
                this.avator=avator;
                this.favourite_singer=favourite_singer;
                this.favourite_song=favourite_song;
                this.signature=signature;
                this.sex=sex;
            }

        }

        static class Song{
            public long songId;
            public String songName;
            public String singer;
            public String type;
            public long popularity;
            public String songAvator;
            public String URL;
            public String lrc;

            public Song(){

            }

            public Song(long songId, String songName, String singer, String type,long popularity,String songAvator,String URL,String lrc){
                this.songId=songId;
                this.songName=songName;
                this.singer=singer;
                this.type=type;
                this.popularity=popularity;
                this.songAvator=songAvator;
                this.URL=URL;
                this.lrc=lrc;
            }
        }
        static class Songs{  //歌曲集合
            public ArrayList<Song> songs=new ArrayList<Song>();
        }

        static class SongList{ //歌单
            public long listId;
            public String listName;
            public String type;
            public String listAvator;
            public Songs songs;

            public SongList(){

            }

            public SongList(long listId,String listName,String type,String listAvator,Songs songs){
                this.listId=listId;
                this.listName=listName;
                this.type=type;
                this.listAvator=listAvator;
                this.songs=songs;
            }
        }

        static class SongLists{
            public ArrayList<SongList> songLists=new ArrayList<SongList>();
        }

        static class userSongLists{
            public String account;
            public SongLists mycreate;
            public SongLists mycollect;

            public userSongLists(){

            }

            public userSongLists(String account,SongLists mycreate, SongLists mycollect){
                this.account=account;
                this.mycreate=mycreate;
                this.mycollect=mycollect;
            }
        }


        static class Comment{
            public long commentId;
            public String account;
            public String content;
            public Long songId;
            public String time;
            public long rCommentId;
            public long like;

            public Comment(){

            }
            public Comment(long commentId,String account,String content,Long songId,String time,long rCommentId, long like){
                this.commentId=commentId;
                this.account=account;
                this.content=content;
                this.songId=songId;
                this.time=time;
                this.rCommentId=rCommentId;
                this.like=like;
            }
        }


        static class Comments{
            public ArrayList<Comment> comments=new ArrayList<Comment>();
        }



        static class File{
            public String filename;
            public File(){
                filename=null;
            }
            public File(String filename){
                this.filename=filename;
            }
        }

        static class list_song{
            public Long listId;
            public Long songId;
            public list_song(Long listId,Long songId){
                this.listId=listId;
                this.songId=songId;
            }
        }

        static class NewSonglist{
            public String account;
            public String listname;
        }

        static class DeleteSonglist{
            public Long listId;
        }
        static class Users{
            public ArrayList<User> userList=new ArrayList<User>();
        }

        static class user_list{
            public Long user_list_id;
            public String account;
            public Long listId;
            public Long isCreate;
        }

    }





%>
