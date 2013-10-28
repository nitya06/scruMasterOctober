package com.neev.controller

import grails.converters.*
import groovy.json.JsonBuilder
import com.neev.domain.*
import com.neev.mainservice.TaskInfoService
import com.neev.mainservice.*
import com.neev.userservice.*
import org.codehaus.groovy.grails.web.json.JSONArray
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class TaskController 
{
    final Logger logger = LoggerFactory.getLogger(TaskController.class)
    JsonBuilder builder = new JsonBuilder();
    def taskInfoService
    def commonUserValidationService
    def getUserService
    
    /*
     *Parameters : No Parameters
     *Functionality : 
     *Return :
    */
    def index() { }
    
    /*
     *Parameters : No Parameters
     *Functionality : Call add method of TaskInfoService
     *Return :
     */
    def add()
    {
        def json = request.JSON
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {    
            if(taskInfoService.isHasSprint(user,json))
            {
                def result = taskInfoService.add(json,user)
                if( result == "notSave" )
                {
                    builder.response(status:"please fill the mandatory field",code:"600");    
                    render builder.toString();
                }
                else if( result == "save" )
                {
                    builder.response(status:"Your data is save !",code:"200")
                    render builder.toString()
                } 
                else
                {
                    builder.response(status:result,code:"300")
                    render builder.toString()
                }  
            }
            else
            {
                builder.response(status:"user doesnt have this Sprint",code:"300")
                render builder.toString()
            }
       }
       else
       {
            builder.response(status:"user authentication fail",code:"500")
            render builder.toString()
       }
    }

    /*
     *Parameters : No Parameters
     *Functionality : Call update method of TaskInfoService
     *Return :
     */
    def update()
    {
       
        def json = request.JSON
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {
            def result = taskInfoService.update(json)
            if( result == "update" )
            {
                builder.response(status:"user authentication success and Data updated",code:"200")
                render builder.toString()
            }
            else if( result == "notUpdate" )
            {
                builder.response(status:"some information is wrong !!! data not updated",code:"600")
                render builder.toString()
            }
            else
            {
                builder.response(status:result,code:"300")
                render builder.toString()
            }
        }
        else
        {
            builder.response(status:"user authentication fail",code:"500")
            render builder.toString()
        }
    }
    
    /*
     *Parameters : No Parameters
     *Functionality : Call get method of TaskInfoService
     *Return :
     */
    
    
    
  def getPageCountForTasks()
  
      
   {
       def json = params
       def user = commonUserValidationService.verifySessionToken(json.token)
       if(user)
       {
              def todoCount = 0
              def in_progressCount = 0
              def completedCount = 0
              
              List list = taskInfoService.get(json) 
             
              for(def i = 0 ; i <list.size() ; i++)
              {
                  if( list.status[i] == "Todo" )
                    todoCount++
                  else if ( list.status[i] == "In Progress" )
                    in_progressCount++
                  else if ( list.status[i] == "Completed" )
                     completedCount++
              }
              
              if(json.filterOption == "All")
              {
                   builder.response( "code": 200,"pageCount": list.size() )
                   render builder.toString()
              }
              else if(json.filterOption == "Todo")
              {
                   builder.response( "code": 200,"pageCount": todoCount  )
                   render builder.toString()
              }
              else if(json.filterOption == "In Progress")
              {
                   builder.response( "code": 200,"pageCount": in_progressCount  )
                   render builder.toString()
              }
              else if(json.filterOption == "Completed")
              {
                   builder.response( "code": 200,"pageCount": completedCount  )
                   render builder.toString()
              }
       }
       else
       {
           builder.response(status:"user authentication fail",code:"500")
           render builder.toString()
       }   
   }
    
    
    
    def get()
    {
        def json = params
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {   
            if(taskInfoService.isHasSprint(user,json))
            {   
               
                List list1 = taskInfoService.get(json)
                def list = new ArrayList()
                def count = 0 
              
                if(json.filterOption == "Todo")
                { 
                    for (def temp = 0 ; temp<list1.size() ; temp++)
                    {
                      if(list1.status[temp] == "Todo")
                          {
                              list[count] = list1[temp]
                              count++
                          }
                    }
                }
                else if (json.filterOption == "In Progress")
                {
                    for (def temp = 0 ; temp<list1.size() ; temp++)
                    {
                      if(list1.status[temp] == "In Progress")
                          {
                              list[count] = list1[temp]
                              count++
                          }
                    }
                }
                else if (json.filterOption == "Completed")
                {
                    for (def temp = 0 ; temp<list1.size() ; temp++)
                    {
                      if(list1.status[temp] == "Completed")
                          {
                             list[count] = list1[temp]
                             
                              count++
                          }
                    }
                }
                else
                {
                    list = list1
                }
             
              JSONArray id = new JSONArray()
              JSONArray name = new JSONArray()
              JSONArray description = new JSONArray()
              JSONArray status = new JSONArray()
              
              JSONArray assignTo = new JSONArray()
              JSONArray userStory = new JSONArray()
             
             
              int startIndex = (json.firstIndex).toInteger()
              int lastIndex =  (json.lastIndex).toInteger()
             
              def i = 0 
             
              for ( int index = startIndex ; index <= lastIndex ; index++)
              { 
                  id[i] = list.id[index]
                  name[i] = list.name[index]
                  description[i] = list.description[index]
                  status[i] = list.status[index]
                  
                  if( list.user[index] == null)
                  {
                      assignTo[i] = "Not Assigned"
                  }
                  else
                  {
                      assignTo[i] = list.user[index].email
                  }
                  
                  if( list.userStory[index] == null)
                  {
                      userStory[i] = "No Backlog here"
                  }
                  else
                  {
                      userStory[i] = list.userStory[index].name
                  }
                 
                  i++
              }
               println "aayr is =============" +assignTo
              builder.response("code": 200,"id": id,"name": name,"description":description, "status":status,"assignTo":assignTo,"userStory":userStory)
              render builder.toString()   
           
                               
            }
            else
            {
                builder.response(status:"user doesnt have this sprint",code:"200")
                render builder.toString()
            }
        }
        else
        {
            builder.response(status:"user authentication fail",code:"500")
            render builder.toString()
        }
    }
    
    
    
   
    
    
    
    /*
     *Parameters : No Parameters
     *Functionality : Call getAllUsers method of GetUserService if user exist with the sesionToken
     *Return :
     */
    def getAllUsers()
    {
        def json = params
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {
            List list = getUserService.getAllUsers()
            render list as JSON
        }
        else
        {
            builder.response(status:"user authentication fail",code:"500")
            render builder.toString()
        }   
    }
    
    def addTaskFromReleaseBoard()
    {
        def json = request.JSON
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {    
            
                def result = taskInfoService.addTaskFromReleaseBoard(json,user)
                if( result == "notSave" )
                {
                    builder.response(status:"please select sprint and user story!!!!!",code:"800");    
                    render builder.toString();
                }
                else if( result == "save" )
                {
                    builder.response(status:"Your data is save !!!!!",code:"200")
                    render builder.toString()
                } 
                else
                {
                    builder.response(status:result,code:"300")
                    render builder.toString()
                }
       }
       else
       {
            builder.response(status:"user authentication fail",code:"500")
            render builder.toString()
       }
    }
    
    
    def getPageCountForAllTask()
    {
       def json = params
       def user = commonUserValidationService.verifySessionToken(json.token)
       if(user)
       {
             
              List list = taskInfoService.getPageCountForAllTask(json) 
              builder.response( "code": 200,"pageCount": list.size() )
              render builder.toString()      
             
       }
       else
       {
           builder.response(status:"user authentication fail",code:"500")
           render builder.toString()
       }   
    }
    def fetchAllTaskForSpecificProject()
    {
       def json = params
       def user = commonUserValidationService.verifySessionToken(json.token)
       if(user)
       {
                 
              List list = taskInfoService.getPageCountForAllTask(json) 
              JSONArray id = new JSONArray()
              JSONArray name = new JSONArray()
              JSONArray description = new JSONArray()
              JSONArray status = new JSONArray()
              JSONArray assignTo = new JSONArray()
              JSONArray userStory = new JSONArray()
              JSONArray sprint = new JSONArray()
             
              int startIndex = (json.firstIndex).toInteger()
              int lastIndex =  (json.lastIndex).toInteger()
             
              def i = 0 
             
               if( lastIndex >= list.size() )
               {
                    lastIndex = list.size()-1
               }
               
              for ( int index = startIndex ; index <= lastIndex ; index++)
              { 
                  id[i] = list.id[index]
                  name[i] = list.name[index]
                  description[i] = list.description[index]
                  status[i] = list.status[index]
                 
                  if( list.user[index] == null)
                  {
                      assignTo[i] = "Not Assigned"
                  }
                  else
                  {
                      assignTo[i] = list.user[index].email
                  }
                  
                  if( list.userStory[index] == null)
                  {
                      userStory[i] = "No Backlog here"
                  }
                  else
                  {
                      userStory[i] = list.userStory[index].name
                  }
                  //
                  if( list.sprint[index] == null)
                  {
                      sprint[i] = "Not assigned to any Sprint"
                  }
                  else
                  {
                      sprint[i] = list.sprint[index].name
                  }

                  i++
              }
              builder.response("code": 200,"id": id,"name": name,"description":description, "status":status,"assignTo":assignTo,"userStory":userStory,"sprint_name":sprint)
              render builder.toString()   
             
       }
       else
       {
           builder.response(status:"user authentication fail",code:"500")
           render builder.toString()
       }   
    }
    
    def fetchTaskInfo()
    {
        def json = params
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {
            Task task  = taskInfoService.fetchTaskInfo(json)
            builder.response("code": 200,"sprintName":task.sprint?.name,"assignTo":task.user?.email,"userStory":task.userStory?.name)
            render builder.toString()
        }
    }
    
    
    def updateTaskFromAllTask()
    {
        def json = request.JSON
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {
        
            if( taskInfoService.updateTaskFromAllTask(json) )
            {
                 builder.response(status:"updated",code:"200")
                 render builder.toString()
            }

        }
    }
}