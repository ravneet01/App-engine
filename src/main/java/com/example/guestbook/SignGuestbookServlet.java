/**
 * Copyright 2014-2015 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//[START all]
package com.example.guestbook;

import com.google.appengine.api.datastore.*;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.googlecode.objectify.ObjectifyService;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;

//queries import

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;

// ...


/**
 * Form Handling Servlet
 * Most of the action for this sample is in webapp/guestbook.jsp, which displays the
 * {@link Greeting}'s. This servlet has one method
 * {@link #doPost(<#HttpServletRequest req#>, <#HttpServletResponse resp#>)} which takes the form
 * data and saves it.
 */
public class SignGuestbookServlet extends HttpServlet {

  // Process the http POST of the form
  @Override
  public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    Greeting greeting;
    //queries

    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    //Creting entity
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Entity ent_greetings ;
 ent_greetings  = new Entity("Greeting");


    String guestbookName = req.getParameter("guestbookName");
    String content = req.getParameter("content");
    Date date = new Date();

    ent_greetings.setProperty("date", date);

    if (user != null) {
      ent_greetings.setProperty("guestbookName", guestbookName);
      ent_greetings.setProperty("content", content);
      greeting = new Greeting(guestbookName, content, user.getUserId(), user.getEmail());

    } else {
      greeting = new Greeting(guestbookName, content);
      ent_greetings.setProperty("guestbookName", guestbookName);
      ent_greetings.setProperty("content", content);
    }
    datastore.put(ent_greetings);



    //update entity
      //DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
      try{
   Key greetKey = KeyFactory.createKey("Guestbook", guestbookName);
    Entity ent_greets = datastore.get(greetKey);
    ent_greetings.setProperty("date", "29/12/2015");
    datastore.put(ent_greetings);

    //update entity
//Retriving entity

           greetKey = KeyFactory.createKey("Guestbook", guestbookName);
           ent_greets = datastore.get(greetKey);
          Query query = new Query("Greeting", ent_greets.getKey()).addSort("date", Query.SortDirection.ASCENDING);
          List<Entity> greet = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(10));


  //delete entity



  //delete
 // datastore.delete(greetKey);
  String url = "/guestbook.jsp";
  ServletContext sc = getServletContext();
  RequestDispatcher rd = sc.getRequestDispatcher(url);
  rd.forward(req, resp);
}
     catch (Exception e) {
      e.printStackTrace();
    }
// Place greeting in same entity group as guestbook
   /*Entity greetings = new Entity("Greeting", guestbookKey);

    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

    //Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
   // Query query = new Query("Greeting", guestbookKey)
            .setAncestor(guestbookKey)
            .addSort("date", Query.SortDirection.DESCENDING);


    //Queries
  /*  DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Entity guestbook = new Entity("Guestbook");
    Key<Guestbook> theBook = Key.create(Guestbook.class, guestbookName);
    guestbook = datastore.get(theBook);*/
// ... set properties ...

    // datastore.put(guestbook);
    // Use Objectify to save the greeting and now() is used to make the call synchronously as we
    // will immediately get a new page using redirect and we want the data to be present.

    ObjectifyService.ofy().save().entity(greeting).now();

    resp.sendRedirect("/guestbook.jsp?guestbookName=" + guestbookName);

  }
}
//[END all]
