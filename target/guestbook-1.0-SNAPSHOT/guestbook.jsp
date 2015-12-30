<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.guestbook.Greeting" %>
<%@ page import="com.example.guestbook.Guestbook" %>

<%@ page import="com.googlecode.objectify.ObjectifyService" %>
<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.appengine.api.urlfetch.FetchOptions" %>
<%@ page import="javax.swing.text.html.parser.Entity" %>
<%@ page import="com.google.appengine.api.datastore.*" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
    int k=0;
    ArrayList<String> l1 = new ArrayList<String>();
    ArrayList<String> l2 = new ArrayList<String>();
    ArrayList<String> g1 = new ArrayList<String>();
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
        g1.add(guestbookName);
        k++;
    }
    g1.add(guestbookName);
    k++;
    pageContext.setAttribute("guestbookName", guestbookName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
        pageContext.setAttribute("user", user);
%>
<%//person is sign in , give link for signout%>
<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>


<%
} else {
    //give sign in link
%>
<p>Hello!
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
    to include your name with greetings you post.</p>
<%
    }
%>
<%
    DatastoreService datastore= DatastoreServiceFactory.getDatastoreService();
    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
    Query query= new Query("Greeting",guestbookKey).addSort("date",Query.SortDirection.DESCENDING);
   // Query query = new Query("Greeting");//this will just list
    //PreparedQuery pq = datastore.prepare(query);


    List<com.google.appengine.api.datastore.Entity> greet = datastore.prepare(query).asList(com.google.appengine.api.datastore.FetchOptions.Builder.withLimit(10));


%>
<%//- See more at: http://www.javawebtutor.com/articles/jsp/jspform.html#sthash.TaiD53tD.dpuf%>
<%-- //[START datastore]--%>
<%
    // Create the correct Ancestor key
    //Key<Guestbook> theBook = Key.create(Guestbook.class, guestbookName);



    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging <p><b>${fn:escapeXml(greeting_user)}</b> wrote:</p>

    List<Greeting> greetings = ObjectifyService.ofy()
            .load()
            .type(Greeting.class) // We want only Greetings
            .ancestor(guestbookKey)    // Anyone in this book
            .order("-date")       // Most recent first - date is indexed.
            .limit(5)             // Only show 5 of them.
            .list();

    if (greetings.isEmpty()) {
%>
<p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
<%
} else {
%>
<p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
<%String author;
    g1.add(guestbookName);
%>
<%
    // Look at all of our greetings
    for (Greeting greeting : greetings) {
        pageContext.setAttribute("greeting_content", greeting.content);


        if (greeting.author_email == null) {
            author = "An anonymous person";
        } else {
            author = greeting.author_email;
            String author_id = greeting.author_id;

            if (user != null && user.getUserId().equals(author_id)) {
                author += " (You)";
            }
        }
        pageContext.setAttribute("greeting_user", author);

        l1.add(author);
        l2.add(greeting.content);
//rough
          /*  for(Greeting i : greetings)
            {
                pageContext.setAttribute("grt_content",i.content);

                pageContext.setAttribute("grt_user",author);

                           */

%>

<p><b>${fn:escapeXml(greeting_user)}</b> wrote:</p>
<blockquote>${fn:escapeXml(greeting_content)}</blockquote>



<%
        }

    }
%>


<form action="/sign" method="post">
    <div><textarea name="content" rows="3" cols="60"></textarea></div>
    <div><input type="submit" value="Post Greeting"/></div>
    <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
</form>
<%-- //[END datastore]--%>
<form action="/guestbook.jsp" method="get">
    <div><input type="text" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/></div>
    <div><input type="submit" value="Switch Guestbook"/></div>
</form>

<%
   // String
    for(int i=0;i<greet.size();i++)
    {
      //  listuser = l1.get(i);
      //  listcontent = l2.get(i);
        pageContext.setAttribute("list_user", greet.get(i));
       // pageContext.setAttribute("list_content", content);


%>

<p>Username: <b>${fn:escapeXml(list_user)}</b></p>

<%

    }
%>

%>
<%--
<table border="1">
    <tr>
        <th>User Names</th>
        <th>Contents</th>
    </tr>
        <tr>
            <td>${fn:escapeXml(greet.author)}</td>
            <td>${fn:escapeXml(greet.content)}</td>
        </tr>
    </c:forEach>
</table>
<%--
<%
    String listuser;
    String listcontent;
    String guest;
    int j=0;
    while(j<k)
    {
        guest = g1.get(j);
        pageContext.setAttribute("guestbook", guest);
%>  <p>Current guestbook: <b>${fn:escapeXml(guestbook)}</b></p>
<% for(int i=0; i<l1.size();i++)
{


    listuser = l1.get(i);
    listcontent = l2.get(i);
    pageContext.setAttribute("list_user", listuser);
    pageContext.setAttribute("list_content", listcontent);


%>

<p>Username: <b>${fn:escapeXml(list_user)}</b></p>
<p>Content:${fn:escapeXml(list_content)}</p>
<%
        }
        j++;
    }
%>

<%

%> --%>
</body>
</html>
<%-- //[END all]--%>
