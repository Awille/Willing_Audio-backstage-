<%--
  Created by IntelliJ IDEA.
  User: wille
  Date: 2017/12/31
  Time: 15:44
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="DatabaseAccess.jsp" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.*,java.util.*, org.apache.commons.io.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="java.awt.List" %>
<%@ page import="com.mysql.jdbc.StringUtils" %>

<%
    System.out.println("photohrer");
    if(request.getMethod().equalsIgnoreCase("post")){
        System.out.println("asdnkasdnkasdn");

        DatabaseAccess.establishConnection();

        String intent=request.getParameter("intent");
        String pid=request.getParameter("pid");

        System.out.println("intent: "+intent);
        System.out.println("pid: "+pid);

        Boolean isMultipart =ServletFileUpload.isMultipartContent(request);

        if(isMultipart){
            Gson gson=new Gson();
            FileItemFactory factory=new DiskFileItemFactory();
            ServletFileUpload upload=new ServletFileUpload(factory);
            try {
                java.util.List item = upload.parseRequest(request);
                Integer i=0;
                while (i<item.size()){
                    FileItem fi=(FileItem) item.get(i);
                    if(fi.isFormField()){
                        //为表单数据 啥也不干
                    }
                    else {
                        String whole_filename=fi.getName();
                        Integer dot_position=whole_filename.lastIndexOf(".");
                        String filename=whole_filename.substring(0,dot_position);
                        String extend=whole_filename.substring(dot_position);
                        DiskFileItem dfi=(DiskFileItem) fi;
                        if(!fi.getName().trim().equals("")){
                            String file_name=FilenameUtils.getName(dfi.getName());
                            if (file_name.endsWith(".jpg") ||
                                    file_name.endsWith(".png") ||
                                    file_name.endsWith(".jpeg") ||
                                    file_name.endsWith(".gif")){
                                //String new_file_name=(filename+new Date()).toString().trim()+extend;
                                String new_file_name=filename+(new Date()).toString().replace(" ","").replace(":","")+extend;
                                String path=new String("");
                                Boolean ok=false;
                                Json.File file_en=new Json.File();
                                file_en.filename=new_file_name;
                                if(intent.equals("modify_user_avator")){
                                    path=application.getRealPath("uploads/UserAvator")
                                            +System.getProperty("file.separator")
                                            +new_file_name;
                                    dfi.write(new File(path));
                                    Json.User user=new Json.User();
                                    user.account=pid;
                                    user.avator=new_file_name;
                                    ok=DatabaseAccess.modifyAvator(user);
                                }
                                else if(intent.equals("modify_song_avator")){
                                    path=application.getRealPath("uploads/SongAvator")
                                            +System.getProperty("file.separator")
                                            +new_file_name;
                                    dfi.write(new File(path));
                                    Json.Song song=new Json.Song();
                                    song.songAvator=new_file_name;
                                    song.songId=Long.parseLong(pid);

                                    ok=DatabaseAccess.modifySongAvator(song);
                                }
                                else if(intent.equals("modify_list_avator")){
                                    System.out.println("here come");
                                    path=application.getRealPath("uploads/ListAvator")
                                            +System.getProperty("file.separator")
                                            +new_file_name;
                                    dfi.write(new File(path));
                                    Json.SongList songList=new Json.SongList();
                                    songList.listAvator=new_file_name;
                                    songList.listId=Long.parseLong(pid);

                                    ok=DatabaseAccess.modifyListAvator(songList);
                                    System.out.println("change suncess? "+ok);
                                }
                                if(ok){
                                    out.print(gson.toJson(new Json.Message("success","uplaod success",file_en)));
                                }
                                else{
                                    out.print(gson.toJson(new Json.Message("error","uplaod fail")));
                                }
                            }
                        }
                    }
                    i++;
                }


            }
            catch (Exception e){
                e.printStackTrace();
                out.print(gson.toJson(new Json.Message("error","upload fail")));
            }

        }
        DatabaseAccess.closeConnection();
    }
%>
